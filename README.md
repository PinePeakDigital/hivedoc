# hivedoc

## Migration

Install the Hedgedoc CLI and include it in your PATH.

```bash
git clone https://github.com/hedgedoc/cli
cd cli/bin
ln -s $PWD/hedgedoc /usr/local/bin/hedgedoc
```

Copy `.env.example` to `.env` and set contained variables.

Save a file with all etherpad note IDs, one per line.

Run the migration script:

```bash
./migrate-etherpad.sh /path/to/etherpad-notes.txt
```
