set :environment, "production"
set :output, "./log/cron_log.log"

every 1.days, :at => '4:00 am' do
	runner "Repository.sync_all"
end

every 1.days, :at => '1:00 am' do
	runner "BackupConfiguration.run_backups"
end

every :monday, :at => '1:00 am' do
	runner "FileSearch.detect_versions"
end