#!/usr/bin/env nu

def main [location: string] {
    echo $"Selected location: ($location)"

    cd $location

    mut installedVersion = ""
    try {
        $installedVersion = (open resources/build_info.json | $in.version)
        echo $"Installed version is ($installedVersion). Checking available..."
    } catch {
        let input = input -u "\n" $"No installed version found. Continue installing anyway? \(y/[n]) "
        if $input != y { exit 0 }
    }
    let url = http head -R m https://discord.com/api/download/stable?platform=linux&format=tar.gz | where name == location | $in.0.value
    let availableVersion = $url | split row / | $in.5
    if $installedVersion == $availableVersion {
        let input = input -u "\n" $"No new version available. Reinstall version ($availableVersion)? \(y/[n]) "
        if $input != y { exit 0 }
    } else if $installedVersion != "" {
        let input = input -u "\n" $"New version available \(($availableVersion)). Install? \([y]/n)"
        if $input != y and $input != "" { exit 0 }
    }
    echo $"Downloading version ($availableVersion)..."
    http get $url | save -f discord.tar.gz
    echo "Unpacking..."
    ls | where name != discord.tar.gz | each { rm -r $in.name }
    tar -xf discord.tar.gz
    mv Discord archive
    mv archive/* .
    rm archive
    rm discord.tar.gz
    echo "Done."
}
