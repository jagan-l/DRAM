# Changelog

All notable changes to this project will be documented in this file.

## 2.0.0-beta17 - 2025-09-23

[1ede0d5](https://github.com/WrightonLabCSU/DRAM/commit/1ede0d53641fdd286218ea3a4b5c6a832b951905)...[ab7b133](https://github.com/WrightonLabCSU/DRAM/commit/ab7b1330ca290887d7b8d435c9b135355980689e)

### Bug Fixes

- Allow calling quast with arbitrary large no of inputs ([e965d31](https://github.com/WrightonLabCSU/DRAM/commit/e965d3100f3543aebc6d24e6a6e186522e456c09))

Quast requires passing inputs as a space seperated list of files,
instead of a dir or other methods. This can run into ARG_MAX limits
So change it to passing a glob, such as `*.fa` instead. This should
fix the problem. We might need to move to batching at some point
for performance reasons.

### Features

- Rename ID col in GFF file ([690cff7](https://github.com/WrightonLabCSU/DRAM/commit/690cff78c978d40f5e814a2949c23ce5a8549116))

In the Prodigal GFF file, the metadata ID field is a generated
unique ID that is in the format 1_1, 1_2, 2_1, 2_2, etc.
This is a problem if people concatenate all the GFFs together since
then the unique IDs aren't unique. In DRAM1, the IDs were repalced
with the SeqID_Genenumber. So that is what we are doing here

We also replaced the python script that parsed the GFF into a summary
TSV for later use in DRAM2 into a tsv and replaced with with bash
parsing. Which benchmarking showed to be around 10-50 times faster.

## 2.0.0-beta16 - 2025-09-17

[216f992](https://github.com/WrightonLabCSU/DRAM/commit/216f99253b1fbdb2d00e70ccabeb35d71f55ab91)...[47e3eaa](https://github.com/WrightonLabCSU/DRAM/commit/47e3eaad03d476596725e3d6a398b68184e094e1)

### Features

- Add nf-test ([6f801af](https://github.com/WrightonLabCSU/DRAM/commit/6f801af84314424d1d3e5b1df083e36e59605f10))

Add nf-test to check DRAM2 vs DRAM1 output
as well as a way to snapshot test DRAM2 changes
for major changes in the future.
First tests include annotation.tsv checks and fixes.

### Bug

- Fix TRNA_COLLECT and COMBINE_ANNOTATIONS for large # inputs ([319ba9b](https://github.com/WrightonLabCSU/DRAM/commit/319ba9b7b54e756cab09c76eb3b412f93d6e7da9))

rewrite TRNA_COLLECT to use pandas vectorized functions instead of
embedded for loops to significantly streamline creation of
collected_trnas.tsv with large # of inputs. Now instead of taking
hours or days, it will run in seconds or minutes.

rewrite COMBINTE_ANNOTATIONS to take directories of inputs instead
of a cli list of files so that when you have thousands and
thousands of mags or assemblies you don't run into your system's
ARG_MAX.

## 2.0.0-beta15 - 2025-08-27

### What's Changed
* Bugfixes with passing in already called genes by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/439
  -  Bugfixes with passing in rrna sheets and trna sheets
  - Bugfixees for namespace errors for starting from called genes that caused runs to crash
*  Add in non hit genes back into raw annotations like they were in DRAM1 by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/439
* Allow job limits (cpu, mem, time) be controlled by config by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/440
* Add adjectives CAZy parsing and ability to pass in custom rules sheet by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/441

## 2.0.0-beta13 - 2025-07-29

### Bug Fixes

- Fix bug with combine annotations nf getting files not as paths (and not getting staged properly) ([06b5294](06b5294c25d6890ca2cef74d31bb899150177190))

### What's Changed
* Fix issues with combine annotations and distill sheets binding issues, by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/436
* Package/update nf core template by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/437

## 2.0.0-beta12 - 2025-07-08

### What's Changed
* Fix bug where merops annotation didn't extract family and distill didn't have family to use by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/433

## 2.0.0-beta11 - 2025-06-11

### What's Changed
* Add slurm_node config option (nodelist) by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/429

## 2.0.0-beta10 - 2025-06-07

### What's Changed
* Feature/adjectives MVP - Add in adjectives minimum viable product by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/423
* Add a contributing docs page by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/424
* Bugfix/merops in distill not correct - Merops wasn't showing up in Distill, revert distill implementation to DRAM1 code by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/428
* Bug discovered with Pfam annotations and distill in DRAM2, Pfam has been disabled for the time being and will be reenabled in the next release or two.

## 2.0.0-beta9 - 2025-05-22

### Bugfix

* In the last version of DRAM2, due to column renames not making it to dram_vix, cazy (dbcan), merops, and pfam all were not being process correctly from DRAM2's annotation file. This led to them just not showing up in the resulting product. Now they should show up, but still have support for the older format that is outputted in DRAM1.
  * Update dram_viz to 0.1.7 because of product bugfix about column names. See dram_viz [release 0.1.7](https://github.com/WrightonLabCSU/dram-viz/releases/tag/0.1.7)

## 2.0.0-beta7 - 2025-05-12

### What's Changed
* Prodigal mode update and quast L50 output by @madeline-scyphers in 0a82b03ea577debd5d83d0e355c61a53697f69ad
* Add camper distill option by @madeline-scyphers in 9d0f087362a6371686015451c6c6da779df16fe0
* Add check for kegg,ko,dbcan, or merops when running distill by @madeline-scyphers in 8bfbe3146dd8d00a445d70303e757ef186171253
* Update distill sheets by @jmikayla1991 in f2b5d74e7cf82251575ed99e87174247d68127e5 and e6c82c48f5a03abb1f6b9c9248b037c4dc4ec264 and 2e860f5b5a07b8a5afe4d0287ba9dd90a0c82d7f
* Docs/add sphinx by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/414
* Update sphinx theme by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/415
* Update config for nf-schema and readthedocs by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/418

## 2.0.0-beta6 - 2025-04-03

### What's Changed
* Replace sample with input_fasta for output by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/404
* Changing rename to run all fasta at once instead of 1 at a time by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/406
* Package/refactor for older nextflow by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/407
* Docs/update docs for new refactor by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/409
* Package/restructure to nf core style by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/410

### BREAKING

Old DRAM2 config no longer works, please replace with new DRAM2 config

### Summary

Move to [nf-core](https://nf-co.re) style nextflow structure. Allowing more flexibility, easier user deployment on different HPC environments and easier user customization (such as customizing memory and time per job easier). Other benefits include a community of support, developed Nextflow tools and plugins that we can and are now tapping to. Easier testing. Already written instition HPC configs, and more.

- [Add nf-core assets for slack report emails, etc.](https://github.com/WrightonLabCSU/DRAM/commit/f6ffbb2848048a63ed86f0ea7db38042d7f5a7e7)
- [Simplify annotate NF workflow](https://github.com/WrightonLabCSU/DRAM/commit/3b625a8021d6d2a5ae05cbebaa7aad9cdcf2f66d)
- [Replace sample with input_fasta for output](https://github.com/WrightonLabCSU/DRAM/commit/e61535daeeb20f81e875c2359a4931104f4e2820) 
in DRAM 1, output (like raw-annotations) like had the column fasta
in DRAM 2 it was renamed to sample, which is incorrect since it isn't
the sample, it is the fasta. Reverting it to fasta like in DRAM 1
is a bit more logistically difficult because a large number of
nf processes (nf functions), and some python files use fasta
for the fastas file paths. So replacing sample with fasta
would cause collisions, and therefore we would need to first
replace all fasta keyworks with something like fasta_path
and then all sample with fasta. This route was easier
and probably less likely to introduce bugs.
- [Changing rename to run all fasta at once instead of 1 at a time](https://github.com/WrightonLabCSU/DRAM/commit/2c3445195332cb8bff675f3d43d5579d3d3d5a13) 
rename currently runs 1 fasta at a time which means for  things
like slurm it submits 1 job per fasta. rename takes in the realm
of seconds. It is much more efficient to batch them together.
- [downgrade nf-schema to 2.0.1 so nextflow can be down to 23 or even 22…](https://github.com/WrightonLabCSU/DRAM/commit/2033031709749b4e532cc40daa2448a0035425d0) 
… something so known users stuck on 23.something can use DRAM 2
- [Update rename for dependencies](https://github.com/WrightonLabCSU/DRAM/commit/e7a61a562638635716b53a9a7fe5198fad87a83e)
- [Update modules code to include wave seqera container](https://github.com/WrightonLabCSU/DRAM/commit/cc9b372f1aae59fa94aabcef3944d4d37e6077e2) 
using wave-cli, with cmd
for every module in modules/local, then adding the outputted url to
container outputer.url for the modules nextflow script, under the conda line.
This allows users to not just use conda, but also containers, and we don't have to build them
Ideally this would be added to a CI, but I haven't see where nf-core is doing that with a CI yet.
- [Add kegg formatting option](https://github.com/WrightonLabCSU/DRAM/commit/45bb6dfa5c421679840e861a4faf8b3b8e5664db)
- [Add processes to modules.conf](https://github.com/WrightonLabCSU/DRAM/commit/518c1dfc5760a940b34241f468f8e25cef61a724) 
Add processes to modules.conf to add publishDir information so they output
their contents where I want them to.
Also added process labels to processes so that NF knows cpus, memory, and time
limits to give different processes.
- [Add slurm option to launch with slurm executor](https://github.com/WrightonLabCSU/DRAM/commit/a55cddf07936762cb980e16fcc9a4b2e136092b8)
- [Update README with some basic install instructions](https://github.com/WrightonLabCSU/DRAM/commit/0db581c820b5dabe41a5fb6469557f7e1f6b276c)

## 2.0.0-beta5 - 2024-11-05

[f415e92](f415e92fc55d228abcc1eeff911a79e09da35adb)...[42fdba0](42fdba01108598af073b048f12a6501f92de5b73)

Fix typo causing bug in main script

## 2.0.0-beta4 - 2024-11-05

[c94d0d4](c94d0d4c5010d9885506915e6c1b37d64f3c7f83)...[f415e92](f415e92fc55d228abcc1eeff911a79e09da35adb)

### What's Changed
* Give default to ch_distill_sql_script since it is used always in annotations by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/383
* Bugfix/path creation bug by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/385
* Feature/kegg pep directory by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM/pull/387

## 2.0.0-beta3 - 2024-10-15

### What's Changed

DRAM v2 is wrapped in Nextflow due to its innate scalability on HPCs and containerization, ensuring rigorous reproducibility and version control, thus making it ideally suited for high-performance computing environments. It was also containerized to give users the option to use with Docker, Singularity or other container runtimes, or still with Conda. Databases have also now been largely preformatted for users. All of this is part of the goal making DRAM easier to install and use, as well as easier to scale.

#### Pre Beta

* Nextflow initial wrapping
* DRAM package restructuring for Nextflow
* Database preformatting changes
* Containerization

### Previous Betas from old repo

#### Beta 1 
* Removed hard-coded slurm node and slurm_queue in nextflow.config by @BioRRW in https://github.com/WrightonLabCSU/DRAM2/pull/1
* Dev by @BioRRW in #2 - https://github.com/WrightonLabCSU/DRAM2/pull/13 
* Visualizations/make product by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/12
* Dev by @BioRRW in https://github.com/WrightonLabCSU/DRAM2/pull/14
* Visualizations/docstrings by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/15
* Add README to visualization package by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/16
* Viz/move viz to installable package by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/20
* Feature/kegg db formatting by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/23
* Package/add docker file by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/24
* Kegg formating, docker, visualization package, dev notes by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/19

#### Beta2
* Replace many ./ paths with using NF's projectDir variable by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/25
* Config/split config by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/26
* Update docs with new install instructions by @madeline-scyphers in https://github.com/WrightonLabCSU/DRAM2/pull/27

#### Beta 3
* Move from DRAM2 name back to DRAM
* Moving DRAM Nextflow Configuration to split better between internal and user


<!-- generated by git-cliff -->
