# Godot class reference status

View the completion status of the Godot class reference (updated daily).

## [View](https://godotengine.github.io/doc-status/)

## How it works

- First, `build.sh` performs the following operations:
  - Clone the Godot Git repository to a temporary directory.
  - Run `doc/tools/status.py` to generate a Markdown table, with the output
    redirected to a file. A static header is added at the beginning of the file
    as well.
  - Some text manipulation is done on the generated Markdown file to improve
    readability and visual grepping.
- [Hugo](https://gohugo.io/) is used to build the HTML template with the
  referenced Markdown data into a static HTML page.
- The generated website is deployed to GitHub Pages.

Every day, there's a continuous integration step that runs the tasks above to
keep the page up-to-date.

## Development

Follow these instructions to set up this site locally for development purposes:

- [Install Hugo](https://gohugo.io/getting-started/installing/) for your
  operating system.
- Run the `build.sh` script to clone the Godot repository, generate a Markdown
  file and build the website.
  - On Windows 10, you should be able to run this script using the WSL.
- Run `hugo server` while working on the website CSS/JavaScript. The local
  server will reload automatically on file changes.
  - If you need to regenerate `content/_index.md`, run `build.sh` again. You can
    do this while having the development server running.

## License

- Copyright (c) 2007-2020 Juan Linietsky, Ariel Manzur.
- Copyright (c) 2014-2020 Godot Engine contributors
  (cf. <https://github.com/godotengine/godot/blob/master/AUTHORS.md>).

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.txt](LICENSE.txt) for more information.
