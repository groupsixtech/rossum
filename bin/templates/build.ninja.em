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
#   - @pkg.manifest.name.replace(" ", "_")
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
@[if preprocess_karel]@
  command = "@(ktransw.path)" $
               -q @(keepgpp)@(preprocess_karel) $
               $lib_includes $
               /I"@(ktrans.support.path)" $
               $macros $
               $in $
               /ver @(ktrans.support.version_string) $
               /config "@(ws.robot_ini.path)"
  depfile = $out.d
  deps = gcc
@[else]@
  command = "@(ktransw.path)" $
               -q @(keepgpp) $
               -MM -MP -MT $out -MF $out.d $
               --ktrans="@(ktrans.path)" $
               $lib_includes $
               /I"@(ktrans.support.path)" $
               $macros $
               $in $
               /ver @(ktrans.support.version_string) $
               /config "@(ws.robot_ini.path)"
  depfile = $out.d
  deps = gcc
@[end if]@

@[if compiletp]@
# .ls -> .tp
#
# Run ls files through
rule maketp_tp
  command = "@(tools['maketp']['path'])" $
               $in $
               /config "@(ws.robot_ini.path)"
@[else]@
# .ls -> .ls
#
# Run ls files through
rule maketp_ls
  command = "@(tools['maketp']['path'])" /y /q $
               $in $
               "$build_dir" $
@[end if]@

@[if hastpp]@
@[if compiletp]@
# .tpp -> .tp
#
# Run ls files through
rule tpp_tp
  command = "@(tools['tpp']['path'])" $
               $in $
               -o $out @[if len(ws.robot_ini.env) > 0]@ -e "@(ws.robot_ini.env)"@[end if]@  $
               @[if makeenv]@ -k "@(makeenv['name']), @(makeenv['clear']), @(makeenv['config'])" @[end if]@ $
               @[if keepgpp]@ -p @[end if]@ $
               $lib_includes $
               && "@(tools['tpp']['compile'])" $out /config "@(ws.robot_ini.path)" $
               && del $out
@[else]@
# .tpp -> .ls
#
# Run ls files through
rule tpp_ls
  command = "@(tools['tpp']['path'])" $
               $in $
               -o $out @[if len(ws.robot_ini.env) > 0]@ -e "@(ws.robot_ini.env)"@[end if]@  $
               @[if makeenv]@ -k "@(makeenv['name']), @(makeenv['clear']), @(makeenv['config'])" @[end if]@ $
               @[if keepgpp]@ -p @[end if]@ $
               $lib_includes $
@[end if]@
@[end if]@



# .yaml -> .xml
#
rule yaml_xml
  command = "@(tools['yaml']['path'])" $
               $in $
               $out $

# .xml -> .xml
#
rule xml_xml
  command = "@(tools['xml']['path'])" /y /q $
               $in $
               "$build_dir" $

# .csv -> .csv
#
rule csv_csv
  command = "@(tools['csv']['path'])" /y /q $
               $in $
               "$build_dir" $

# .utx -> .tx, .vr
#
rule utx_tx
  command = "@(tools['kcdict']['path'])" $
               @(keepgpp) $
               $lib_includes $
               $in $
               "$build_dir" $
               /config "@(ws.robot_ini.path)"

# .ftx -> .tx, .vr
#
rule ftx_tx
  command = "@(tools['kcform']['path'])" $
               @(keepgpp) $
               $lib_includes $
               $in $
               "$build_dir" $
               /config "@(ws.robot_ini.path)"


### build statements ###########################################################

@[for pkg in ws.pkgs]@
@# don't generate rules for packages that don't have any objects declared
@[if len(pkg.objects) > 0]@
### @(pkg.manifest.name.replace(" ", "_")) ###################

@(pkg.manifest.name.replace(" ", "_"))_dir = @(pkg.location)
@(pkg.manifest.name.replace(" ", "_"))_deps = @(str.join(' ', [d.manifest.name for d in pkg.dependencies]))
@(pkg.manifest.name.replace(" ", "_"))_include_flags = @(str.join(' ', ['/I"{0}"'.format(d) for d in pkg.include_dirs]))
@(pkg.manifest.name.replace(" ", "_"))_macros = @(str.join(' ', ['/D{0}'.format(d) for d in pkg.macros]))

@[for (src, obj, _, _) in pkg.objects]@
build $build_dir\@(obj): @
@[if '.kl' in src.lower()]@ ktrans_pc @[end if]@ @
@[if '.ls' in src.lower() and compiletp]@ maketp_tp @[end if]@ @
@[if '.ls' in src.lower() and not compiletp]@ maketp_ls @[end if]@ @
@[if '.tpp' in src.lower() and compiletp]@ tpp_tp @[end if]@ @
@[if '.tpp' in src.lower() and not compiletp]@ tpp_ls @[end if]@ @
@[if '.yml' in src.lower()]@ yaml_xml @[end if]@ @
@[if '.xml' in src.lower()]@ xml_xml @[end if]@ @
@[if '.csv' in src.lower()]@ csv_csv @[end if]@ @
@[if '.utx' in src.lower()]@ utx_tx @[end if]@ @
@[if '.ftx' in src.lower()]@ ftx_tx @[end if]@ @
$@(pkg.manifest.name.replace(" ", "_"))_dir\@(src)
  macros = $@(pkg.manifest.name.replace(" ", "_"))_macros
  lib_includes = $@(pkg.manifest.name.replace(" ", "_"))_include_flags
  description = @(pkg.manifest.name.replace(" ", "_")) :: @(src)

@[end for]@

@# TODO: add tests

@# pkg in ws.pkgs
@[end if]@
@[end for]@
