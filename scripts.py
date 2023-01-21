import json

def main():
    mods = json.load(open('mods.json', 'r', encoding='utf-8'))
    mod_keys = sorted(list(mods.keys()))

    contents = [
        '# Minecraft Settings',
        '## Mods',
        '| Name | License |',
        '| ---- | ------- |',
    ]

    for mod_key in mod_keys:
        mod = mods[mod_key]

        contents.append('| [{name}]({url}) | {license} |'.format(
            name=mod['name'],
            url=mod['url'],
            license=mod['license'] if 'license' in mod else '-',
        ))

    with open('README.md', 'w', encoding='utf-8') as file:
        file.write('\n'.join(contents))

if __name__ == '__main__':
    main()
