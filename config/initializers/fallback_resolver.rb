class DefaultHtmlTemplateFormat < ActionView::FileSystemResolver
    def initialize path
      super(path)
    end

    def find_templates(name, prefix, partial, details)
        templates = super(name, prefix, partial, details)
        return templates if templates.present?

        unless details[:formats] == [:html]
            new_details = details.dup
            new_details[:formats] = [:html]
            templates = super(name, prefix, partial, new_details)
        end
        return templates
    end
end

ActiveSupport.on_load(:action_controller) do
    view_paths.each do |path|
        append_view_path(DefaultHtmlTemplateFormat.new(path.to_s))
    end
end