# Kubefigs

Simple configuration management for kubernetes configs

## Usage

```
docker run -v $(pwd):/data -e "SRC=/data/path/to/configs/" nyulibraries/kubefigs
```

Where `path/to/configs/` is a relative path to your config templates, files with extensions `.tpl`. Kubefigs will look for a file in this directory named `_variables.yml`. This file will have variables under different environments, and these environments will be used to create new subdirectories. The subdirectories will have files created from the templates and interpolated with the respective variables from the variables file. The interpolation syntax in the template files is the same as used in shell interpolation, e.g. `${variable_name}`

You may run against a specific file:

```
docker run -v $(pwd):/data -e "SRC=/data/path/config.yml.tpl" nyulibraries/kubefigs
```

You can also specify the variables file:

```
docker run -v $(pwd):/data -e "SRC=/data/path/config.yml.tpl" -e "VARS=/data/path/alt_variables.yml" nyulibraries/kubefigs
```

### Example

For example, given a config file `configs/my_config.yml.tpl`:

```
some_value: ${val1}
```

And a variables file `configs/_variables.yml`:

```
dev:
  val1: development
prod:
  val2: production
```

We execute `docker run -v $(pwd):/data -e "SRC=/data/configs/" nyulibraries/kubefigs` to get two new files, `configs/dev/my_config.yml`:

```
some_value: development
```

And `configs/prod/my_config.yml`

```
some_value: production
```
