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
    "gamemode": 2,
    "ops": "whatupdave\\nchrislloyd",
    "seed": "s33d",
    "allow-nether": true,
    "allow-flight": false,
    "spawn-animals": true,
    "spawn-monsters": false,
    "spawn-npcs": false,
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

task :publish do
  paths = %w(bin template Gemfile Gemfile.lock funpack.json)
  system %Q{
    archive-dir http://party-cloud-production.s3.amazonaws.com/funpacks/slugs/team-fortress-2/stable.tar.lzo #{paths.join(' ')}
  }
end