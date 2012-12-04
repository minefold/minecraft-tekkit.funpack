task :default => :test

task :test do
  system %Q{
    rm -rf tmp/1234
    mkdir -p tmp/1234/working
    cp -R test-world/* tmp/1234/working
  }

  File.write 'tmp/1234/server.json', <<-EOS
{
  "id": "1234",
  "port": 4032,
  "ram": {
    "min": 1024,
    "max": 1024
  },
  "settings" : {
    "blacklist": "atnan",
    "game_mode": 1,
    "ops": "whatupdave\\nchrislloyd",
    "seed": 123456789,
    "spawn_animals": "1",
    "spawn_monsters": "1",
    "spawn_npcs": "0",
    "whitelist": "whatupdave\\nchrislloyd"
  }
}
EOS

  run = File.expand_path 'bin/run'

  Dir.chdir('tmp/1234/working') do
    raise "error" unless system "#{run} ../server.json"
  end
end

desc "Update Tekkit server"
task :update_tekkit do
  system "curl -L http://cbukk.it/craftbukkit-beta.jar > template/craftbukkit.jar"
end