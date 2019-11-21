@###############################################################################
@#
@# Copyright (c) 2016, G.A. vd. Hoorn
@#
@# Licensed under the Apache License, Version 2.0 (the "License");
@# you may not use this file except in compliance with the License.
@# You may obtain a copy of the License at
@#
@#     http://www.apache.org/licenses/LICENSE-2.0
@#
@# Unless required by applicable law or agreed to in writing, software
@# distributed under the License is distributed on an "AS IS" BASIS,
@# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@# See the License for the specific language governing permissions and
@# limitations under the License.
@#
@###############################################################################
@#
@# rossum ninja build script EmPy template
@#
@#
@# Author: G.A. vd. Hoorn
@#
@###############################################################################
################################################################################
#
# This file was auto-generated by rossum v@(rossum_version) at @(tstamp).
#
# Package directories searched at configuration time:
#
@[for pkg_dir in ws.sources]@
#   @pkg_dir.path
@[end for]@
#
# Packages build by this build file:
#
@[for pkg in ws.pkgs]@
#   - @pkg.manifest.name
@[end for]@
#
# Do not modify this file. Rather, regenerate it using rossum.
#
################################################################################


### build setup ################################################################

build_dir = @(ws.build.path)


### build rules ################################################################

# .kl -> .pc
#
# this rule always places the Karel support directory corresponding to the
# runtime version on the include path, as that is a globally needed path.
rule ktrans_pc
  command = @(ktransw.path) $
               -q $
               -MM -MP -MT $out -MF $out.d $
               --ktrans="@(ktrans.path)" $
               $lib_includes $
               /I"@(ktrans.support.path)" $
               $in $
               /ver @(ktrans.support.version_string) $
               /config "@(ws.robot_ini.path)"
  depfile = $out.d
  deps = gcc

# .ls -> .tp
#
# Run ls files through
rule maketp_tp
  command = @(tools['maketp']['path']) $
               $in $
               /config "@(ws.robot_ini.path)"

# .tpp -> .ls
#
# Run ls files through
rule tpp_ls
  command = @(tools['tpp']['path']) $
               $in $
               -o $out
               @[if len(ws.robot_ini.env) > 0]-e "@(ws.robot_ini.env)"@[end if]@

# .yaml -> .xml
#
# Run ls files through
rule yaml_xml
  command = @(tools['yaml']['path']) $
               $in $
               $out $


### build statements ###########################################################

@[for pkg in ws.pkgs]@
@# don't generate rules for packages that don't have any objects declared
@[if len(pkg.objects) > 0]@
### @(pkg.manifest.name) ###################

@(pkg.manifest.name)_dir = @(pkg.location)
@(pkg.manifest.name)_deps = @(str.join(' ', [d.manifest.name for d in pkg.dependencies]))
@(pkg.manifest.name)_include_flags = @(str.join(' ', ['/I"{0}"'.format(d) for d in pkg.include_dirs]))

@[for (src, obj) in pkg.objects]@
build $build_dir\@(obj): @
@[if '.kl' in src]@ ktrans_pc @[end if]@ @
@[if '.ls' in src]@ maketp_tp @[end if]@ @
@[if '.tpp' in src]@ tpp_ls @[end if]@ @
@[if '.yml' in src]@ yaml_xml @[end if]@ @
$@(pkg.manifest.name)_dir\@(src)
  lib_includes = $@(pkg.manifest.name)_include_flags
  description = @(pkg.manifest.name) :: @(src)

@[end for]@

@# TODO: add tests

@# pkg in ws.pkgs
@[end if]@
@[end for]@
