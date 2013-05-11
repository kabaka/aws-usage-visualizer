# Simple S3 Web Site Creator

I needed a quick and dirty way to rapidly convert a set of Markdown files into
a templated web site and put it on S3. Rake seemed like a great tool for the
job, so I wrote this.

Since this is largely just a personal tool, documentation is going to be scarce
and vague for the time being. I am still feeling out the direction I want to
take this and determining how to solve some basic design problems as they
arise.

*Expect to run into problems or weird behavior.* I can't emphasize how much
this has been tailored to my needs and nothing beyond them (as yet).

## Usage

These instructions are somewhat disjointed and may be confusing. If you don't
understand them, you are probably better off waiting for the tool to become
more mature.

### Configuration

See `config.yaml.dist`. Create a `config.yaml` based on it.

### Basic Template

Create a `templates` directory. In it, create a file called `html.erb`. In this
file, you should use the following variables:

* `title` - the page title, determined by the source file name
* `body` - the page body, either rendered from markdown or directly copied from
  a raw HTML file

The `html.erb` file will be rendered as an `erb` template normally is.

### Source Files

Create a `source-files` directory. Inside that, you may have:

* `static-assets` - assets copied as-is to /static-assets/ in the S3 bucket
* `pages` - markdown or other files that are copied to the root of the S3
  bucket. Markdown (`.md` or `.markdown`) files are rendered to HTML using
  Kramdown.

### Rake

The tool is invoked by the `rake` utility.

* `rake` - generate all content and upload to S3
* `rake regen` - clear local cache and regenerate content without uploading
* `rake local:clean` - clear local cache
* `rake local:generate` - generate local cache
* `rake s3:upload` - upload local cache to S3

