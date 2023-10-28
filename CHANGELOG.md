# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v8.0.0](https://github.com/voxpupuli/puppet-consul/tree/v8.0.0) (2023-10-31)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.3.1...v8.0.0)

**Breaking changes:**

- Update default version 1.16.1-\>1.16.3 [\#643](https://github.com/voxpupuli/puppet-consul/pull/643) ([bastelfreak](https://github.com/bastelfreak))
- Update default consul version 1.2.3-\>1.16.1 [\#637](https://github.com/voxpupuli/puppet-consul/pull/637) ([bastelfreak](https://github.com/bastelfreak))
- Drop Puppet 6 support [\#626](https://github.com/voxpupuli/puppet-consul/pull/626) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add AlmaLinux/Rocky support [\#646](https://github.com/voxpupuli/puppet-consul/pull/646) ([bastelfreak](https://github.com/bastelfreak))
- Add EL9 support [\#645](https://github.com/voxpupuli/puppet-consul/pull/645) ([bastelfreak](https://github.com/bastelfreak))
- Add Debian 12 support [\#644](https://github.com/voxpupuli/puppet-consul/pull/644) ([bastelfreak](https://github.com/bastelfreak))
- Add Puppet 8 support [\#628](https://github.com/voxpupuli/puppet-consul/pull/628) ([bastelfreak](https://github.com/bastelfreak))
- bump puppet/systemd to \< 5.0.0 [\#622](https://github.com/voxpupuli/puppet-consul/pull/622) ([jhoblitt](https://github.com/jhoblitt))
- Implement Sensitive support for config [\#614](https://github.com/voxpupuli/puppet-consul/pull/614) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- fixed systemd err "Failed to parse service type, ignoring: exec" [\#641](https://github.com/voxpupuli/puppet-consul/pull/641) ([fb929](https://github.com/fb929))
- CI: Use Type=exec instead of Type=notify [\#638](https://github.com/voxpupuli/puppet-consul/pull/638) ([bastelfreak](https://github.com/bastelfreak))
- systemd template: add missing space [\#635](https://github.com/voxpupuli/puppet-consul/pull/635) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- systemd Failed to parse service type, ignoring: exec [\#640](https://github.com/voxpupuli/puppet-consul/issues/640)
- Adding ACLS / Policies failes with unable to get local issuer certificate -\> Puppet 6 / LetsEncrypt [\#623](https://github.com/voxpupuli/puppet-consul/issues/623)

**Merged pull requests:**

- enhance acceptance tests [\#639](https://github.com/voxpupuli/puppet-consul/pull/639) ([bastelfreak](https://github.com/bastelfreak))
- Replace legacy merge\(\) with native puppet code [\#636](https://github.com/voxpupuli/puppet-consul/pull/636) ([bastelfreak](https://github.com/bastelfreak))
- puppet/hashi\_stack: Allow 3.x [\#634](https://github.com/voxpupuli/puppet-consul/pull/634) ([bastelfreak](https://github.com/bastelfreak))
- puppet/archive: Allow 7.x [\#633](https://github.com/voxpupuli/puppet-consul/pull/633) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#632](https://github.com/voxpupuli/puppet-consul/pull/632) ([bastelfreak](https://github.com/bastelfreak))
- puppet/systemd: Allow 5.x [\#631](https://github.com/voxpupuli/puppet-consul/pull/631) ([bastelfreak](https://github.com/bastelfreak))
- Update metadata.json [\#624](https://github.com/voxpupuli/puppet-consul/pull/624) ([kengelhardt-godaddy](https://github.com/kengelhardt-godaddy))
- correct original author in README.md [\#620](https://github.com/voxpupuli/puppet-consul/pull/620) ([bastelfreak](https://github.com/bastelfreak))
- README.md: fix wrong camptocamp references [\#619](https://github.com/voxpupuli/puppet-consul/pull/619) ([bastelfreak](https://github.com/bastelfreak))
- puppet-lint: enforce parameter documentation [\#618](https://github.com/voxpupuli/puppet-consul/pull/618) ([bastelfreak](https://github.com/bastelfreak))
- Convert classes to puppet-strings [\#617](https://github.com/voxpupuli/puppet-consul/pull/617) ([bastelfreak](https://github.com/bastelfreak))
- mark internal classes as private [\#616](https://github.com/voxpupuli/puppet-consul/pull/616) ([bastelfreak](https://github.com/bastelfreak))
- systemd service: Switch erb to epp template [\#615](https://github.com/voxpupuli/puppet-consul/pull/615) ([bastelfreak](https://github.com/bastelfreak))

## [v7.3.1](https://github.com/voxpupuli/puppet-consul/tree/v7.3.1) (2022-10-26)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.3.0...v7.3.1)

**Fixed bugs:**

- manage\_repo: ensure that we refresh the package list before installing consul [\#612](https://github.com/voxpupuli/puppet-consul/pull/612) ([bastelfreak](https://github.com/bastelfreak))

## [v7.3.0](https://github.com/voxpupuli/puppet-consul/tree/v7.3.0) (2022-10-24)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.2.0...v7.3.0)

**Implemented enhancements:**

- Drop legacy init scripts [\#609](https://github.com/voxpupuli/puppet-consul/pull/609) ([bastelfreak](https://github.com/bastelfreak))
- Add Debian 11 support [\#608](https://github.com/voxpupuli/puppet-consul/pull/608) ([bastelfreak](https://github.com/bastelfreak))
- Add Ubuntu 22.04 support [\#607](https://github.com/voxpupuli/puppet-consul/pull/607) ([bastelfreak](https://github.com/bastelfreak))
- Document and test package based installation [\#606](https://github.com/voxpupuli/puppet-consul/pull/606) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Package install: Fix ordering when data\_dir isnt managed [\#610](https://github.com/voxpupuli/puppet-consul/pull/610) ([bastelfreak](https://github.com/bastelfreak))

## [v7.2.0](https://github.com/voxpupuli/puppet-consul/tree/v7.2.0) (2022-08-22)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.1.0...v7.2.0)

**Implemented enhancements:**

- Support Service and Nodemeta for queries [\#597](https://github.com/voxpupuli/puppet-consul/pull/597) ([jardleex](https://github.com/jardleex))

**Closed issues:**

- legacy ACL v1 no longer working  starting from Consul version 1.11 [\#588](https://github.com/voxpupuli/puppet-consul/issues/588)

## [v7.1.0](https://github.com/voxpupuli/puppet-consul/tree/v7.1.0) (2022-04-20)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.0.2...v7.1.0)

**Implemented enhancements:**

- Adding datacenters property for Consul policies [\#590](https://github.com/voxpupuli/puppet-consul/pull/590) ([jonesbrennan](https://github.com/jonesbrennan))
- Add special rule format for keyring type policy [\#582](https://github.com/voxpupuli/puppet-consul/pull/582) ([weastur](https://github.com/weastur))
- Allow changing the configuration directory and files owner [\#535](https://github.com/voxpupuli/puppet-consul/pull/535) ([thias](https://github.com/thias))

**Closed issues:**

- migrate module to Vox Pupuli? [\#576](https://github.com/voxpupuli/puppet-consul/issues/576)
- info required - Apply ACL on https consul [\#517](https://github.com/voxpupuli/puppet-consul/issues/517)

**Merged pull requests:**

- puppet/archive & puppetlabs/stdli: Allow latest versions [\#594](https://github.com/voxpupuli/puppet-consul/pull/594) ([bastelfreak](https://github.com/bastelfreak))
- Cleanup metadata.json/README.md after migration [\#593](https://github.com/voxpupuli/puppet-consul/pull/593) ([bastelfreak](https://github.com/bastelfreak))
- updating README.md for consul version compatibility [\#592](https://github.com/voxpupuli/puppet-consul/pull/592) ([jonesbrennan](https://github.com/jonesbrennan))
- Switch from camptocamp/systemd to puppet/systemd [\#586](https://github.com/voxpupuli/puppet-consul/pull/586) ([bastelfreak](https://github.com/bastelfreak))
- Run unit tests on CI [\#583](https://github.com/voxpupuli/puppet-consul/pull/583) ([weastur](https://github.com/weastur))

## [v7.0.2](https://github.com/voxpupuli/puppet-consul/tree/v7.0.2) (2021-06-12)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.0.1...v7.0.2)

**Closed issues:**

- Module Release? [\#578](https://github.com/voxpupuli/puppet-consul/issues/578)

**Merged pull requests:**

- enable ssl when protocol is https [\#577](https://github.com/voxpupuli/puppet-consul/pull/577) ([SimonPe](https://github.com/SimonPe))

## [v7.0.1](https://github.com/voxpupuli/puppet-consul/tree/v7.0.1) (2021-06-12)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v7.0.0...v7.0.1)

**Fixed bugs:**

- Make home directory location setting optional [\#575](https://github.com/voxpupuli/puppet-consul/pull/575) ([genebean](https://github.com/genebean))

**Closed issues:**

- Migrate from master to main [\#572](https://github.com/voxpupuli/puppet-consul/issues/572)
- New Home Attribute on consul user resource breaks our puppet runs. [\#559](https://github.com/voxpupuli/puppet-consul/issues/559)
- Compatibility with Puppet 3.6 [\#503](https://github.com/voxpupuli/puppet-consul/issues/503)
- upgrade puppetlabs-stdlib version in dependencies to \< 7.0.0? [\#496](https://github.com/voxpupuli/puppet-consul/issues/496)
- service weights needs integer [\#492](https://github.com/voxpupuli/puppet-consul/issues/492)

**Merged pull requests:**

- Release v7.0.0 [\#574](https://github.com/voxpupuli/puppet-consul/pull/574) ([solarkennedy](https://github.com/solarkennedy))

## [v7.0.0](https://github.com/voxpupuli/puppet-consul/tree/v7.0.0) (2021-05-12)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v6.1.0...v7.0.0)

**Breaking changes:**

- Drop support for EoL Puppet 5 [\#571](https://github.com/voxpupuli/puppet-consul/issues/571)
- Drop support for old SLES/SLED versions [\#570](https://github.com/voxpupuli/puppet-consul/issues/570)
- Drop EoL FreeBSD 10 support [\#569](https://github.com/voxpupuli/puppet-consul/issues/569)
- Drop EoL Fedora 25/26/27 support [\#568](https://github.com/voxpupuli/puppet-consul/issues/568)
- Drop EoL Amazon Linux support [\#567](https://github.com/voxpupuli/puppet-consul/issues/567)
- Drop EoL Ubuntu 16.04 support  [\#566](https://github.com/voxpupuli/puppet-consul/issues/566)
- Drop EoL CentOS/RHEL 6 support [\#565](https://github.com/voxpupuli/puppet-consul/issues/565)
- consul user: set correct home [\#550](https://github.com/voxpupuli/puppet-consul/pull/550) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow for alias\_service checks [\#520](https://github.com/voxpupuli/puppet-consul/pull/520) ([genebean](https://github.com/genebean))

**Fixed bugs:**

- sorted\_json should quote args for checks [\#548](https://github.com/voxpupuli/puppet-consul/pull/548) ([hdeheer](https://github.com/hdeheer))

**Closed issues:**

- Registering multiple services from same node/instance with same name  [\#562](https://github.com/voxpupuli/puppet-consul/issues/562)
- HCL Config Support [\#557](https://github.com/voxpupuli/puppet-consul/issues/557)
- Can not download the archive. need to allow insecure access to download for archive [\#553](https://github.com/voxpupuli/puppet-consul/issues/553)
- Home directory not created for consul user [\#533](https://github.com/voxpupuli/puppet-consul/issues/533)
- Service port gets quoted with a puppet 6.10 catalog server and consul rejects it [\#526](https://github.com/voxpupuli/puppet-consul/issues/526)

**Merged pull requests:**

- List Debian 10 as supported [\#573](https://github.com/voxpupuli/puppet-consul/pull/573) ([genebean](https://github.com/genebean))
- OS and Puppet versions update [\#564](https://github.com/voxpupuli/puppet-consul/pull/564) ([genebean](https://github.com/genebean))
- PDK update, move CI to GH Actions [\#563](https://github.com/voxpupuli/puppet-consul/pull/563) ([genebean](https://github.com/genebean))
- adding the option to setup the upstream HashiCorp repository [\#560](https://github.com/voxpupuli/puppet-consul/pull/560) ([attachmentgenie](https://github.com/attachmentgenie))
- Add config\_name parameter to define the name of the consul config [\#558](https://github.com/voxpupuli/puppet-consul/pull/558) ([bogdankatishev](https://github.com/bogdankatishev))
- Add description parameter for token [\#556](https://github.com/voxpupuli/puppet-consul/pull/556) ([Hexta](https://github.com/Hexta))
- Add new check options [\#555](https://github.com/voxpupuli/puppet-consul/pull/555) ([Rekenn](https://github.com/Rekenn))
- notify systemd when consul daemon is really started [\#552](https://github.com/voxpupuli/puppet-consul/pull/552) ([ymartin-ovh](https://github.com/ymartin-ovh))
- Added stale bot to close super old issues [\#549](https://github.com/voxpupuli/puppet-consul/pull/549) ([solarkennedy](https://github.com/solarkennedy))
- Make stringification a parameter of the sorted\_json helper functions [\#547](https://github.com/voxpupuli/puppet-consul/pull/547) ([rtkennedy](https://github.com/rtkennedy))

## [v6.1.0](https://github.com/voxpupuli/puppet-consul/tree/v6.1.0) (2020-08-18)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v6.0.1...v6.1.0)

**Fixed bugs:**

- Sysv init script: redirect stderr to logfile [\#545](https://github.com/voxpupuli/puppet-consul/pull/545) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- No obvious support for setting headers for inline service checks [\#542](https://github.com/voxpupuli/puppet-consul/issues/542)
- Add support for Ingress Controllers using Configuration Entries [\#538](https://github.com/voxpupuli/puppet-consul/issues/538)
- Define service without including consul \#question [\#536](https://github.com/voxpupuli/puppet-consul/issues/536)
- What do I need to do to to get the nslcd service started before the Consul service [\#531](https://github.com/voxpupuli/puppet-consul/issues/531)
- Consul user not found in /etc/passwd issue [\#530](https://github.com/voxpupuli/puppet-consul/issues/530)
- Can't set consul watch from hiera [\#518](https://github.com/voxpupuli/puppet-consul/issues/518)
- Clarification - What is acl\_api\_token? [\#505](https://github.com/voxpupuli/puppet-consul/issues/505)
- consul\_token is not idempotent [\#490](https://github.com/voxpupuli/puppet-consul/issues/490)
- Support for External Services  [\#252](https://github.com/voxpupuli/puppet-consul/issues/252)

**Merged pull requests:**

- Add example http service, including a check that demonstrates how to pass headers [\#543](https://github.com/voxpupuli/puppet-consul/pull/543) ([chrisjohnson](https://github.com/chrisjohnson))
- update to support raspberry pi arm arch with Hashicorp splitting out file names [\#540](https://github.com/voxpupuli/puppet-consul/pull/540) ([ikonia](https://github.com/ikonia))
- Fix data\_dir\_mode override [\#534](https://github.com/voxpupuli/puppet-consul/pull/534) ([thias](https://github.com/thias))
- Add acl\_api\_token to service\_reload class [\#532](https://github.com/voxpupuli/puppet-consul/pull/532) ([cmd-ntrf](https://github.com/cmd-ntrf))
- Removing OpenSuSE from metadata.json to stop triggering broken tests [\#529](https://github.com/voxpupuli/puppet-consul/pull/529) ([rtkennedy](https://github.com/rtkennedy))
- Use a filter instead of delete\_undef\_values\(\) [\#528](https://github.com/voxpupuli/puppet-consul/pull/528) ([rtkennedy](https://github.com/rtkennedy))
- Add option to \(un\)manage the data\_dir [\#523](https://github.com/voxpupuli/puppet-consul/pull/523) ([b3n4kh](https://github.com/b3n4kh))
- Fix rubocop LineLength \# see https://rubocop.readthedocs.io/en/latest… [\#521](https://github.com/voxpupuli/puppet-consul/pull/521) ([thomas-merz](https://github.com/thomas-merz))
- fix\(reload\_service\): remove typo in reload\_options [\#516](https://github.com/voxpupuli/puppet-consul/pull/516) ([bmx0r](https://github.com/bmx0r))

## [v6.0.1](https://github.com/voxpupuli/puppet-consul/tree/v6.0.1) (2019-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v6.0.0...v6.0.1)

**Fixed bugs:**

- systemd: Start consul after network is really up [\#512](https://github.com/voxpupuli/puppet-consul/pull/512) ([bastelfreak](https://github.com/bastelfreak))
- Add a sleep between tries of consul service reload [\#494](https://github.com/voxpupuli/puppet-consul/pull/494) ([cmd-ntrf](https://github.com/cmd-ntrf))

**Merged pull requests:**

- release 6.0.1 [\#513](https://github.com/voxpupuli/puppet-consul/pull/513) ([bastelfreak](https://github.com/bastelfreak))

## [v6.0.0](https://github.com/voxpupuli/puppet-consul/tree/v6.0.0) (2019-10-31)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v5.1.0...v6.0.0)

**Breaking changes:**

- drop EOL Debian 8 / Puppet 4 / Ubuntu 14.04 / CentOS 5 [\#508](https://github.com/voxpupuli/puppet-consul/pull/508) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Fix broken quoting in the config file [\#509](https://github.com/voxpupuli/puppet-consul/pull/509) ([maxadamo](https://github.com/maxadamo))
- add support for reload over https [\#504](https://github.com/voxpupuli/puppet-consul/pull/504) ([BCarette](https://github.com/BCarette))

**Closed issues:**

- Add support for CNI plugins [\#502](https://github.com/voxpupuli/puppet-consul/issues/502)
- Example of using ACL's in production? [\#486](https://github.com/voxpupuli/puppet-consul/issues/486)
- Puppetforge README and Github README are different [\#485](https://github.com/voxpupuli/puppet-consul/issues/485)

**Merged pull requests:**

- release 6.0.0 [\#510](https://github.com/voxpupuli/puppet-consul/pull/510) ([bastelfreak](https://github.com/bastelfreak))
- drop puppetlabs/powershell dependency [\#506](https://github.com/voxpupuli/puppet-consul/pull/506) ([bastelfreak](https://github.com/bastelfreak))
- Bump stdlib & archive versions [\#501](https://github.com/voxpupuli/puppet-consul/pull/501) ([jay7x](https://github.com/jay7x))
- remove failing tests on centos6 + puppet 6 [\#500](https://github.com/voxpupuli/puppet-consul/pull/500) ([solarkennedy](https://github.com/solarkennedy))
- systemd template: mention it's managed by puppet [\#495](https://github.com/voxpupuli/puppet-consul/pull/495) ([bastelfreak](https://github.com/bastelfreak))
- Fix typo [\#489](https://github.com/voxpupuli/puppet-consul/pull/489) ([spuder](https://github.com/spuder))
- Clarify how to use the new acl system [\#487](https://github.com/voxpupuli/puppet-consul/pull/487) ([spuder](https://github.com/spuder))

## [v5.1.0](https://github.com/voxpupuli/puppet-consul/tree/v5.1.0) (2019-07-24)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v5.0.4...v5.1.0)

**Implemented enhancements:**

- Lint, style, and parameter data types [\#476](https://github.com/voxpupuli/puppet-consul/pull/476) ([natemccurdy](https://github.com/natemccurdy))
- Support for Consul 1.4.0+ ACL system [\#474](https://github.com/voxpupuli/puppet-consul/pull/474) ([marius-meissner](https://github.com/marius-meissner))
- quote all values of tags, meta & node\_meta [\#473](https://github.com/voxpupuli/puppet-consul/pull/473) ([tmu-sprd](https://github.com/tmu-sprd))

**Closed issues:**

- Feature Request: support special policies like `acl` and `operator` without segment option [\#482](https://github.com/voxpupuli/puppet-consul/issues/482)
- New 1.4+ ACL support is not idempotent [\#479](https://github.com/voxpupuli/puppet-consul/issues/479)
- option to strip binary [\#478](https://github.com/voxpupuli/puppet-consul/issues/478)
- \[Feature request\] Provide support for Consul 1.4.0+ ACL System [\#471](https://github.com/voxpupuli/puppet-consul/issues/471)
- Can we get a new release to forge soon? [\#469](https://github.com/voxpupuli/puppet-consul/issues/469)
- Can't use integer on meta hash on services [\#468](https://github.com/voxpupuli/puppet-consul/issues/468)
- Quoted integer \(string\) to integer is breaking tags [\#283](https://github.com/voxpupuli/puppet-consul/issues/283)

**Merged pull requests:**

- resources 'acl' and 'operator' don't have a segment [\#483](https://github.com/voxpupuli/puppet-consul/pull/483) ([tmu-sprd](https://github.com/tmu-sprd))
- Fixing idempotence issues of new ACL system + improved handling of properties [\#480](https://github.com/voxpupuli/puppet-consul/pull/480) ([marius-meissner](https://github.com/marius-meissner))
- Switch from anchor pattern to contain function [\#475](https://github.com/voxpupuli/puppet-consul/pull/475) ([natemccurdy](https://github.com/natemccurdy))
- fix case where multiple http\_addr [\#470](https://github.com/voxpupuli/puppet-consul/pull/470) ([robmbrooks](https://github.com/robmbrooks))

## [v5.0.4](https://github.com/voxpupuli/puppet-consul/tree/v5.0.4) (2019-02-10)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v5.0.3...v5.0.4)

**Breaking changes:**

- Updated windows support [\#464](https://github.com/voxpupuli/puppet-consul/pull/464) ([KZachariassen](https://github.com/KZachariassen))

**Implemented enhancements:**

- add optional service meta hash [\#466](https://github.com/voxpupuli/puppet-consul/pull/466) ([jardleex](https://github.com/jardleex))
- Add service\_config\_hash to customize services [\#460](https://github.com/voxpupuli/puppet-consul/pull/460) ([dan-wittenberg](https://github.com/dan-wittenberg))

**Fixed bugs:**

- Don't write out meta parameter when unset [\#467](https://github.com/voxpupuli/puppet-consul/pull/467) ([jarro2783](https://github.com/jarro2783))
- Change allow for spaces in the path, Add extra\_options to the win agent [\#459](https://github.com/voxpupuli/puppet-consul/pull/459) ([monkey670](https://github.com/monkey670))

**Merged pull requests:**

- PDK convert, merged changes, pdk validate linter cleanup of pp files [\#463](https://github.com/voxpupuli/puppet-consul/pull/463) ([dan-wittenberg](https://github.com/dan-wittenberg))

## [v5.0.3](https://github.com/voxpupuli/puppet-consul/tree/v5.0.3) (2018-12-15)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v5.0.1...v5.0.3)

**Fixed bugs:**

- Don't monkey-patch the JSON module [\#456](https://github.com/voxpupuli/puppet-consul/pull/456) ([joshuaspence](https://github.com/joshuaspence))

**Closed issues:**

- Systemd fails to start Consul [\#455](https://github.com/voxpupuli/puppet-consul/issues/455)
- Broken JSON module [\#452](https://github.com/voxpupuli/puppet-consul/issues/452)

**Merged pull requests:**

- release 5.0.2 [\#457](https://github.com/voxpupuli/puppet-consul/pull/457) ([bastelfreak](https://github.com/bastelfreak))

## [v5.0.1](https://github.com/voxpupuli/puppet-consul/tree/v5.0.1) (2018-10-31)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v4.0.0...v5.0.1)

**Breaking changes:**

- Puppet 6 support [\#444](https://github.com/voxpupuli/puppet-consul/pull/444) ([l-lotz](https://github.com/l-lotz))
- bump default consul version from 0.7.4 to 1.2.3 [\#443](https://github.com/voxpupuli/puppet-consul/pull/443) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- undefined method `validate_checks` on puppet 5.5.7/6.0.3 [\#448](https://github.com/voxpupuli/puppet-consul/issues/448)
- Wrong init provider on Ubuntu 14.04 [\#438](https://github.com/voxpupuli/puppet-consul/issues/438)
- Change "enableTagOverride" to "enable\_tag\_override" in version 1.0.0 and … [\#447](https://github.com/voxpupuli/puppet-consul/pull/447) ([wenzhengjiang](https://github.com/wenzhengjiang))

**Closed issues:**

- Version 4.0.0 is missing in git [\#445](https://github.com/voxpupuli/puppet-consul/issues/445)
- Wrong dependencies in Puppet Forge [\#442](https://github.com/voxpupuli/puppet-consul/issues/442)

**Merged pull requests:**

- release 5.0.0 [\#449](https://github.com/voxpupuli/puppet-consul/pull/449) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-consul/tree/v4.0.0) (2018-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.4.2...v4.0.0)

## [v3.4.2](https://github.com/voxpupuli/puppet-consul/tree/v3.4.2) (2018-10-03)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.4.1...v3.4.2)

## [v3.4.1](https://github.com/voxpupuli/puppet-consul/tree/v3.4.1) (2018-10-03)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.4.0...v3.4.1)

**Closed issues:**

- Consul version upgrade to 1.2.0 [\#433](https://github.com/voxpupuli/puppet-consul/issues/433)
- Telemetry [\#431](https://github.com/voxpupuli/puppet-consul/issues/431)
- Release version 3.3.1 [\#428](https://github.com/voxpupuli/puppet-consul/issues/428)

**Merged pull requests:**

- Allow puppetlabs-stdlib v5.x [\#440](https://github.com/voxpupuli/puppet-consul/pull/440) ([hfm](https://github.com/hfm))
- allow camptocamp/systemd 2.x [\#439](https://github.com/voxpupuli/puppet-consul/pull/439) ([l-lotz](https://github.com/l-lotz))
- Fix broken testmatrix due to gem updates [\#437](https://github.com/voxpupuli/puppet-consul/pull/437) ([bastelfreak](https://github.com/bastelfreak))
- Update Readme.md to Include Telemetry Settings [\#432](https://github.com/voxpupuli/puppet-consul/pull/432) ([ghost](https://github.com/ghost))

## [v3.4.0](https://github.com/voxpupuli/puppet-consul/tree/v3.4.0) (2018-07-05)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.3.1...v3.4.0)

**Implemented enhancements:**

- Add tests for raft\_multiplier [\#429](https://github.com/voxpupuli/puppet-consul/pull/429) ([bastelfreak](https://github.com/bastelfreak))
- allow management of CAP\_NET\_BIND\_SERVICE via systemd [\#427](https://github.com/voxpupuli/puppet-consul/pull/427) ([bastelfreak](https://github.com/bastelfreak))
- add support for the beta UI [\#417](https://github.com/voxpupuli/puppet-consul/pull/417) ([bastelfreak](https://github.com/bastelfreak))
- Add AArch64 \(arm64\) support [\#409](https://github.com/voxpupuli/puppet-consul/pull/409) ([ajungren](https://github.com/ajungren))
- Add new parameters to configure consul permissions in the binary [\#408](https://github.com/voxpupuli/puppet-consul/pull/408) ([cristianjuve](https://github.com/cristianjuve))
- Support space-separated list in addresses [\#406](https://github.com/voxpupuli/puppet-consul/pull/406) ([sw0x2A](https://github.com/sw0x2A))
- Add `args` parameter to `consul::watch`  [\#404](https://github.com/voxpupuli/puppet-consul/pull/404) ([scottybrisbane](https://github.com/scottybrisbane))

**Fixed bugs:**

- protocol should be a param not property. [\#329](https://github.com/voxpupuli/puppet-consul/pull/329) ([chris-bmj](https://github.com/chris-bmj))

**Closed issues:**

- Performance Raft Multiplier [\#426](https://github.com/voxpupuli/puppet-consul/issues/426)
- Consul 1.1.0 uses a new key for enableTagOverride [\#420](https://github.com/voxpupuli/puppet-consul/issues/420)
- Allow for different consul and consul-ui versions. [\#384](https://github.com/voxpupuli/puppet-consul/issues/384)
- uid/gid [\#353](https://github.com/voxpupuli/puppet-consul/issues/353)
- Run configtest before reloading service [\#338](https://github.com/voxpupuli/puppet-consul/issues/338)
- New prepared queries provider not accepting integers [\#291](https://github.com/voxpupuli/puppet-consul/issues/291)
- Consul binary not found when puppet agent is daemonized [\#290](https://github.com/voxpupuli/puppet-consul/issues/290)
- systemd Client Nodes Not Properly Leaving Cluster on Shutdown [\#282](https://github.com/voxpupuli/puppet-consul/issues/282)
- Add Support for Windows [\#195](https://github.com/voxpupuli/puppet-consul/issues/195)

**Merged pull requests:**

- Release 3.4.0 [\#430](https://github.com/voxpupuli/puppet-consul/pull/430) ([bastelfreak](https://github.com/bastelfreak))
- Add CentOS 6/7 acceptance tests [\#425](https://github.com/voxpupuli/puppet-consul/pull/425) ([bastelfreak](https://github.com/bastelfreak))
- Add Ubuntu 18.04 / 16.04 support [\#424](https://github.com/voxpupuli/puppet-consul/pull/424) ([bastelfreak](https://github.com/bastelfreak))
- Bump archive dependency to allow 3.X releases [\#423](https://github.com/voxpupuli/puppet-consul/pull/423) ([bastelfreak](https://github.com/bastelfreak))
- Use $consul::version instead of facter consul\_version \(Fix 09297fa\) [\#419](https://github.com/voxpupuli/puppet-consul/pull/419) ([hfm](https://github.com/hfm))
- Change enableTagOverride to enable\_tag\_override in Consul 1.1.0 and later [\#418](https://github.com/voxpupuli/puppet-consul/pull/418) ([hfm](https://github.com/hfm))
- enable acceptance tests on travis [\#416](https://github.com/voxpupuli/puppet-consul/pull/416) ([bastelfreak](https://github.com/bastelfreak))

## [v3.3.1](https://github.com/voxpupuli/puppet-consul/tree/v3.3.1) (2018-01-27)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.2.4...v3.3.1)

**Closed issues:**

- module errors on posix systems without unzip [\#402](https://github.com/voxpupuli/puppet-consul/issues/402)
- Support for Amazon 2 OS  [\#396](https://github.com/voxpupuli/puppet-consul/issues/396)
- Latest version doesn't work with Puppet 3.x \(breaking change?\) [\#394](https://github.com/voxpupuli/puppet-consul/issues/394)
- Changing Consul kv values doesn't seem to have an effect [\#374](https://github.com/voxpupuli/puppet-consul/issues/374)
- Clean out fixtures prior to uploading to forge [\#349](https://github.com/voxpupuli/puppet-consul/issues/349)

**Merged pull requests:**

- Added experimental Windows support [\#403](https://github.com/voxpupuli/puppet-consul/pull/403) ([iwagnerclgx](https://github.com/iwagnerclgx))
- Removed command substitution in init script [\#401](https://github.com/voxpupuli/puppet-consul/pull/401) ([tooooots](https://github.com/tooooots))
- Add `args` parameter to `consul::check` [\#400](https://github.com/voxpupuli/puppet-consul/pull/400) ([joshuaspence](https://github.com/joshuaspence))
- Added the ui parameter and removed ui\_\* ones [\#398](https://github.com/voxpupuli/puppet-consul/pull/398) ([rawleto](https://github.com/rawleto))
- support Amazon Linux 2 [\#397](https://github.com/voxpupuli/puppet-consul/pull/397) ([vchan2002](https://github.com/vchan2002))

## [v3.2.4](https://github.com/voxpupuli/puppet-consul/tree/v3.2.4) (2017-12-05)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.2.3...v3.2.4)

**Merged pull requests:**

- set correct namespace for systemd dependency [\#393](https://github.com/voxpupuli/puppet-consul/pull/393) ([bastelfreak](https://github.com/bastelfreak))

## [v3.2.3](https://github.com/voxpupuli/puppet-consul/tree/v3.2.3) (2017-12-05)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.2.2...v3.2.3)

## [v3.2.2](https://github.com/voxpupuli/puppet-consul/tree/v3.2.2) (2017-12-05)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.2.0...v3.2.2)

**Closed issues:**

- consul\_sorted\_json for octal notation of file modes [\#389](https://github.com/voxpupuli/puppet-consul/issues/389)
- Add hiera wrapper for ACL entries. [\#385](https://github.com/voxpupuli/puppet-consul/issues/385)
- Config validation failed [\#383](https://github.com/voxpupuli/puppet-consul/issues/383)
- default config\_dir broken on FreeBSD [\#360](https://github.com/voxpupuli/puppet-consul/issues/360)
- Consul 0.8.0 is out! and it breaks a few things... [\#331](https://github.com/voxpupuli/puppet-consul/issues/331)

**Merged pull requests:**

- simplify systemd setup by using camptocamp/systemd [\#392](https://github.com/voxpupuli/puppet-consul/pull/392) ([bastelfreak](https://github.com/bastelfreak))
- Do not unquote integers with a leading zero [\#391](https://github.com/voxpupuli/puppet-consul/pull/391) ([phaer](https://github.com/phaer))
- replace fedora versions with current supported ones [\#390](https://github.com/voxpupuli/puppet-consul/pull/390) ([bastelfreak](https://github.com/bastelfreak))
- set sane default shell for consul user [\#388](https://github.com/voxpupuli/puppet-consul/pull/388) ([bastelfreak](https://github.com/bastelfreak))
- fix typo in check timeout [\#387](https://github.com/voxpupuli/puppet-consul/pull/387) ([lobeck](https://github.com/lobeck))
- Fixes \#360 by setting config\_dir under FreeBSD [\#386](https://github.com/voxpupuli/puppet-consul/pull/386) ([madelaney](https://github.com/madelaney))
- allow "args" and "script" for consul check config [\#382](https://github.com/voxpupuli/puppet-consul/pull/382) ([zg](https://github.com/zg))
- Breaking: Update Puppet version to 4.7.1 and add data types [\#381](https://github.com/voxpupuli/puppet-consul/pull/381) ([wyardley](https://github.com/wyardley))
- Handle consul\_acl connection refused as a retry-able error [\#336](https://github.com/voxpupuli/puppet-consul/pull/336) ([kpaulisse](https://github.com/kpaulisse))

## [v3.2.0](https://github.com/voxpupuli/puppet-consul/tree/v3.2.0) (2017-11-20)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.1.2...v3.2.0)

**Closed issues:**

- Validate command for config files doesn't work [\#376](https://github.com/voxpupuli/puppet-consul/issues/376)

**Merged pull requests:**

- Removing the consul config check [\#380](https://github.com/voxpupuli/puppet-consul/pull/380) ([Faffnir](https://github.com/Faffnir))
- \[issue/376\] [\#379](https://github.com/voxpupuli/puppet-consul/pull/379) ([khdevel](https://github.com/khdevel))
- Fix updating of Consul KV store [\#378](https://github.com/voxpupuli/puppet-consul/pull/378) ([dannytrigo](https://github.com/dannytrigo))
- Fix validate command for config files in consul 1.0.0 [\#377](https://github.com/voxpupuli/puppet-consul/pull/377) ([Faffnir](https://github.com/Faffnir))

## [v3.1.2](https://github.com/voxpupuli/puppet-consul/tree/v3.1.2) (2017-10-26)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.1.1...v3.1.2)

## [v3.1.1](https://github.com/voxpupuli/puppet-consul/tree/v3.1.1) (2017-10-24)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v3.0.0...v3.1.1)

**Closed issues:**

- what ACL rights required for consul\_acl part to run? [\#373](https://github.com/voxpupuli/puppet-consul/issues/373)
- Consul k/v does not update to new value [\#363](https://github.com/voxpupuli/puppet-consul/issues/363)
- How do you ensure unzip is installed? [\#356](https://github.com/voxpupuli/puppet-consul/issues/356)
- changes to systemd template [\#354](https://github.com/voxpupuli/puppet-consul/issues/354)
- Support for cloud -join switches [\#350](https://github.com/voxpupuli/puppet-consul/issues/350)
- Switch from `%{linenumber}` to `%{line}` in v2 branch [\#346](https://github.com/voxpupuli/puppet-consul/issues/346)
- 3.0.0 not tagged? [\#343](https://github.com/voxpupuli/puppet-consul/issues/343)

**Merged pull requests:**

- Validate config file before deploying [\#372](https://github.com/voxpupuli/puppet-consul/pull/372) ([kasimon](https://github.com/kasimon))
- use proper systemd custom .service directory [\#366](https://github.com/voxpupuli/puppet-consul/pull/366) ([foxxx0](https://github.com/foxxx0))
- \(\#359\) Datacenter support to consul\_key\_value [\#365](https://github.com/voxpupuli/puppet-consul/pull/365) ([houtmanj](https://github.com/houtmanj))
- Don't pin so hard on ruby versions on travis [\#362](https://github.com/voxpupuli/puppet-consul/pull/362) ([solarkennedy](https://github.com/solarkennedy))
- Fix issue with init script [\#361](https://github.com/voxpupuli/puppet-consul/pull/361) ([brandonrdn](https://github.com/brandonrdn))
- added docker support [\#357](https://github.com/voxpupuli/puppet-consul/pull/357) ([Justin-DynamicD](https://github.com/Justin-DynamicD))
- allow to specify a proxy server for package downloads [\#351](https://github.com/voxpupuli/puppet-consul/pull/351) ([xavvo](https://github.com/xavvo))
- Support "Near" parameter in prepared queries [\#348](https://github.com/voxpupuli/puppet-consul/pull/348) ([tlevi](https://github.com/tlevi))
- support other unspecified RedHat variants [\#341](https://github.com/voxpupuli/puppet-consul/pull/341) ([cspargo](https://github.com/cspargo))
- Notify the service when package is updated [\#340](https://github.com/voxpupuli/puppet-consul/pull/340) ([jaxxstorm](https://github.com/jaxxstorm))
- Test changes for property [\#334](https://github.com/voxpupuli/puppet-consul/pull/334) ([jk2l](https://github.com/jk2l))
- Ensure /usr/local/bin is in the path for consul binary [\#313](https://github.com/voxpupuli/puppet-consul/pull/313) ([mspaulding06](https://github.com/mspaulding06))

## [v3.0.0](https://github.com/voxpupuli/puppet-consul/tree/v3.0.0) (2017-04-19)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v2.1.1...v3.0.0)

**Closed issues:**

- Execution of 'unzip -o /var/lib/consul/archives/consul-0.7.4.zip' returned 1:  [\#332](https://github.com/voxpupuli/puppet-consul/issues/332)
- please specify json module version minimum [\#328](https://github.com/voxpupuli/puppet-consul/issues/328)
- Could not look up qualified variable '$::consul\_version' [\#327](https://github.com/voxpupuli/puppet-consul/issues/327)

**Merged pull requests:**

- BREAKING - Consul 0.8.0 fixes [\#337](https://github.com/voxpupuli/puppet-consul/pull/337) ([lobeck](https://github.com/lobeck))

## [v2.1.1](https://github.com/voxpupuli/puppet-consul/tree/v2.1.1) (2017-03-16)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v2.1.0...v2.1.1)

**Closed issues:**

- Curl return code 35 when fetching the consul binary. [\#320](https://github.com/voxpupuli/puppet-consul/issues/320)
- Consul - Error: Invalid parameter temp\_dir\(:temp\_dir\) [\#317](https://github.com/voxpupuli/puppet-consul/issues/317)
- Error: Cannot create /opt/consul/archives; parent directory /opt/consul does not exist [\#311](https://github.com/voxpupuli/puppet-consul/issues/311)
- consul\_acl created on every puppet run [\#211](https://github.com/voxpupuli/puppet-consul/issues/211)

**Merged pull requests:**

- Try pinning more things in fixtures [\#326](https://github.com/voxpupuli/puppet-consul/pull/326) ([solarkennedy](https://github.com/solarkennedy))
- Remove unnecessary .gitkeep files in lib/ [\#325](https://github.com/voxpupuli/puppet-consul/pull/325) ([cosmopetrich](https://github.com/cosmopetrich))
- Fix idempotent issue within key\_value runs. [\#323](https://github.com/voxpupuli/puppet-consul/pull/323) ([jrasell](https://github.com/jrasell))
- Reduce travis matrix [\#322](https://github.com/voxpupuli/puppet-consul/pull/322) ([solarkennedy](https://github.com/solarkennedy))
- Bump default consul version. Improve FreeBSD support [\#319](https://github.com/voxpupuli/puppet-consul/pull/319) ([olevole](https://github.com/olevole))
- fix ::consul\_version fact lookup during installation [\#316](https://github.com/voxpupuli/puppet-consul/pull/316) ([wstiern](https://github.com/wstiern))

## [v2.1.0](https://github.com/voxpupuli/puppet-consul/tree/v2.1.0) (2017-01-12)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v2.0.0...v2.1.0)

**Closed issues:**

- Annoying "defined 'protocol' as 'http' " for every consul\_acl resource [\#310](https://github.com/voxpupuli/puppet-consul/issues/310)
- Issues with default data-dir post-\#292 [\#307](https://github.com/voxpupuli/puppet-consul/issues/307)

**Merged pull requests:**

- Actually fix the changes every run problem [\#315](https://github.com/voxpupuli/puppet-consul/pull/315) ([mrwulf](https://github.com/mrwulf))
- Changes every run [\#312](https://github.com/voxpupuli/puppet-consul/pull/312) ([mrwulf](https://github.com/mrwulf))
- Better acl rules message [\#309](https://github.com/voxpupuli/puppet-consul/pull/309) ([mrwulf](https://github.com/mrwulf))
- Use data\_dir as a the root of the archive path. Fixes \#307 [\#308](https://github.com/voxpupuli/puppet-consul/pull/308) ([solarkennedy](https://github.com/solarkennedy))

## [v2.0.0](https://github.com/voxpupuli/puppet-consul/tree/v2.0.0) (2016-12-29)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.1.0...v2.0.0)

**Implemented enhancements:**

- Support for prepared queries [\#239](https://github.com/voxpupuli/puppet-consul/issues/239)

**Closed issues:**

- cant use latest consul version as parameter [\#305](https://github.com/voxpupuli/puppet-consul/issues/305)
- EC2 Join Support [\#302](https://github.com/voxpupuli/puppet-consul/issues/302)
- Consul user is created with login shell [\#293](https://github.com/voxpupuli/puppet-consul/issues/293)
- Validate and document all params that could be passed to ::consul [\#170](https://github.com/voxpupuli/puppet-consul/issues/170)

**Merged pull requests:**

- Add support of custom log\_file in sles and upstart init scripts [\#306](https://github.com/voxpupuli/puppet-consul/pull/306) ([AlexLov](https://github.com/AlexLov))
- More Systemd unit file improvements [\#304](https://github.com/voxpupuli/puppet-consul/pull/304) ([amiryal](https://github.com/amiryal))
- Check $::consul\_version more correctly [\#303](https://github.com/voxpupuli/puppet-consul/pull/303) ([logic](https://github.com/logic))
- Cleanup Systemd unit file [\#301](https://github.com/voxpupuli/puppet-consul/pull/301) ([amiryal](https://github.com/amiryal))
- Fixing init service start/stop messages and locks [\#300](https://github.com/voxpupuli/puppet-consul/pull/300) ([mrwulf](https://github.com/mrwulf))
- Initial support for FreeBSD platform [\#299](https://github.com/voxpupuli/puppet-consul/pull/299) ([olevole](https://github.com/olevole))
- Revert "Set login shell for consul user to /sbin/nologin" [\#298](https://github.com/voxpupuli/puppet-consul/pull/298) ([solarkennedy](https://github.com/solarkennedy))
- Set login shell for consul user to /sbin/nologin [\#297](https://github.com/voxpupuli/puppet-consul/pull/297) ([madAndroid](https://github.com/madAndroid))
- add support for prepared query templates [\#296](https://github.com/voxpupuli/puppet-consul/pull/296) ([adamcstephens](https://github.com/adamcstephens))
- KV Provider / Prepared Query Bugfixes [\#294](https://github.com/voxpupuli/puppet-consul/pull/294) ([djtaylor](https://github.com/djtaylor))
- BREAKING: Change the default 'archive\_path' to '/opt/consul/archives'. [\#292](https://github.com/voxpupuli/puppet-consul/pull/292) ([jmkeyes](https://github.com/jmkeyes))
- ADD parameter "log\_file" for custom log location [\#289](https://github.com/voxpupuli/puppet-consul/pull/289) ([miso231](https://github.com/miso231))
- Prepared Queries [\#288](https://github.com/voxpupuli/puppet-consul/pull/288) ([djtaylor](https://github.com/djtaylor))
- Catch :undef when pretty-printing in consul\_sorted\_json.rb [\#287](https://github.com/voxpupuli/puppet-consul/pull/287) ([tdevelioglu](https://github.com/tdevelioglu))
- Reduce the travis matrix even more [\#286](https://github.com/voxpupuli/puppet-consul/pull/286) ([solarkennedy](https://github.com/solarkennedy))
- Remove puppet error when ACLs cannot be retrieved [\#285](https://github.com/voxpupuli/puppet-consul/pull/285) ([thejandroman](https://github.com/thejandroman))
- Drop pinning for 1.8.7 as there are no tests for it anymore. [\#281](https://github.com/voxpupuli/puppet-consul/pull/281) ([tdevelioglu](https://github.com/tdevelioglu))

## [v1.1.0](https://github.com/voxpupuli/puppet-consul/tree/v1.1.0) (2016-09-23)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.12...v1.1.0)

**Merged pull requests:**

- Update downloaded version to latest stable \(0.7.0\) [\#280](https://github.com/voxpupuli/puppet-consul/pull/280) ([tdevelioglu](https://github.com/tdevelioglu))

## [v1.0.12](https://github.com/voxpupuli/puppet-consul/tree/v1.0.12) (2016-09-23)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.10...v1.0.12)

**Closed issues:**

- Support for puppet-archive \>=1.0.0 [\#275](https://github.com/voxpupuli/puppet-consul/issues/275)
- Consul service is not starting up [\#273](https://github.com/voxpupuli/puppet-consul/issues/273)
- Question: URL method downloads the zip file every run? [\#270](https://github.com/voxpupuli/puppet-consul/issues/270)
- Add proxy support [\#269](https://github.com/voxpupuli/puppet-consul/issues/269)
- Changelog on Puppetforge not updated for 1.0.9 [\#268](https://github.com/voxpupuli/puppet-consul/issues/268)
- Support talking to Consul over https for ACL operations [\#217](https://github.com/voxpupuli/puppet-consul/issues/217)
- consul\_acl makes api call before ACL api is available [\#193](https://github.com/voxpupuli/puppet-consul/issues/193)

**Merged pull requests:**

- Decouple service from init system [\#279](https://github.com/voxpupuli/puppet-consul/pull/279) ([tdevelioglu](https://github.com/tdevelioglu))
- Polish [\#278](https://github.com/voxpupuli/puppet-consul/pull/278) ([tdevelioglu](https://github.com/tdevelioglu))
- Require a new version of puppet-archive [\#277](https://github.com/voxpupuli/puppet-consul/pull/277) ([solarkennedy](https://github.com/solarkennedy))
- Allow for stable versions of puppet/archive [\#276](https://github.com/voxpupuli/puppet-consul/pull/276) ([ghoneycutt](https://github.com/ghoneycutt))
- add retry logic when contacting the REST API for listing ACL resources [\#274](https://github.com/voxpupuli/puppet-consul/pull/274) ([cjdaniel](https://github.com/cjdaniel))
- Rebase \#218 [\#271](https://github.com/voxpupuli/puppet-consul/pull/271) ([solarkennedy](https://github.com/solarkennedy))

## [v1.0.10](https://github.com/voxpupuli/puppet-consul/tree/v1.0.10) (2016-06-23)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.9...v1.0.10)

## [v1.0.9](https://github.com/voxpupuli/puppet-consul/tree/v1.0.9) (2016-06-20)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.8...v1.0.9)

**Closed issues:**

- enableTagOverride value being written as a quoted string, need to be unquote boolean. [\#261](https://github.com/voxpupuli/puppet-consul/issues/261)
- /opt/consul/serf/local.keyring is not replaced when changing encryption keys [\#256](https://github.com/voxpupuli/puppet-consul/issues/256)
- Error depencie archive [\#253](https://github.com/voxpupuli/puppet-consul/issues/253)
- nanliu-staging dependency  [\#250](https://github.com/voxpupuli/puppet-consul/issues/250)
- chkconfig init files are not setup for consul on CentOS 6 [\#249](https://github.com/voxpupuli/puppet-consul/issues/249)
- Failed to start Raft: permission denied [\#237](https://github.com/voxpupuli/puppet-consul/issues/237)
- Question : Atlas join [\#228](https://github.com/voxpupuli/puppet-consul/issues/228)
- InitV startup script doesn't deamonize proprely [\#210](https://github.com/voxpupuli/puppet-consul/issues/210)
- Consul 0.6 support [\#204](https://github.com/voxpupuli/puppet-consul/issues/204)
- Why is ACL ID read-only? [\#192](https://github.com/voxpupuli/puppet-consul/issues/192)

**Merged pull requests:**

- Configure log file for upstart. [\#265](https://github.com/voxpupuli/puppet-consul/pull/265) ([jdavisp3](https://github.com/jdavisp3))
- Handle nested :undef in consul\_sorted\_json [\#263](https://github.com/voxpupuli/puppet-consul/pull/263) ([mcasper](https://github.com/mcasper))
- drop bool2str as we need a unquoted true|false [\#262](https://github.com/voxpupuli/puppet-consul/pull/262) ([sjoeboo](https://github.com/sjoeboo))
- Added a parameter to allow users to change $install\_path [\#260](https://github.com/voxpupuli/puppet-consul/pull/260) ([tfhartmann](https://github.com/tfhartmann))
- Drop ruby 1.8 support again now that puppet-archive doesn't support it [\#259](https://github.com/voxpupuli/puppet-consul/pull/259) ([solarkennedy](https://github.com/solarkennedy))
- service EnableTagOverride [\#258](https://github.com/voxpupuli/puppet-consul/pull/258) ([cliles](https://github.com/cliles))
- adding ability to define the inital status of consul checks [\#257](https://github.com/voxpupuli/puppet-consul/pull/257) ([asgolding](https://github.com/asgolding))
- Puppet archive install directory will fail if default umask changed [\#255](https://github.com/voxpupuli/puppet-consul/pull/255) ([lynxman](https://github.com/lynxman))
- in dynamic environment consul-agent should be init [\#254](https://github.com/voxpupuli/puppet-consul/pull/254) ([mcortinas](https://github.com/mcortinas))
- fix tests [\#251](https://github.com/voxpupuli/puppet-consul/pull/251) ([solarkennedy](https://github.com/solarkennedy))

## [v1.0.8](https://github.com/voxpupuli/puppet-consul/tree/v1.0.8) (2016-04-13)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.6...v1.0.8)

**Closed issues:**

- Switch from using staging module to archive [\#242](https://github.com/voxpupuli/puppet-consul/issues/242)
- Service start is broken on Debian \> 8.0 [\#232](https://github.com/voxpupuli/puppet-consul/issues/232)
- Services variable not working with hiera hash. Expects an array of hashes it seems. [\#230](https://github.com/voxpupuli/puppet-consul/issues/230)
- ensure\_packages unzip with 'before' breaks interoperability [\#187](https://github.com/voxpupuli/puppet-consul/issues/187)
- Setting consul::version in hiera does not change the download\_url [\#129](https://github.com/voxpupuli/puppet-consul/issues/129)
- add maintenance mode option to init scripts [\#124](https://github.com/voxpupuli/puppet-consul/issues/124)
- Watches key in config\_hash should expect an array of hashes? [\#83](https://github.com/voxpupuli/puppet-consul/issues/83)

## [v1.0.6](https://github.com/voxpupuli/puppet-consul/tree/v1.0.6) (2016-03-24)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.5...v1.0.6)

**Closed issues:**

- Master broken on EL6 due to "Invalid service provider 'sysv'" [\#240](https://github.com/voxpupuli/puppet-consul/issues/240)
- Service reload too quick [\#231](https://github.com/voxpupuli/puppet-consul/issues/231)
- Systemd limits issue [\#225](https://github.com/voxpupuli/puppet-consul/issues/225)
- Encryption [\#224](https://github.com/voxpupuli/puppet-consul/issues/224)
- Duplicate declaration: Class\[Staging\] with puppet/mysql mysqltuner [\#223](https://github.com/voxpupuli/puppet-consul/issues/223)
- Consul reload fails when rpc\_addr is 0.0.0.0 [\#220](https://github.com/voxpupuli/puppet-consul/issues/220)
- Support creating ACLs while talking to a hostname other than localhost [\#216](https://github.com/voxpupuli/puppet-consul/issues/216)
- Release version 1.0.5 [\#215](https://github.com/voxpupuli/puppet-consul/issues/215)

**Merged pull requests:**

- Switching from staging to archive module [\#243](https://github.com/voxpupuli/puppet-consul/pull/243) ([hopperd](https://github.com/hopperd))
- EL \< 7 uses init service provider, not sysv.  [\#241](https://github.com/voxpupuli/puppet-consul/pull/241) ([fatmcgav](https://github.com/fatmcgav))
- Update reload\_service.pp [\#235](https://github.com/voxpupuli/puppet-consul/pull/235) ([nvtkaszpir](https://github.com/nvtkaszpir))
- add support for arm \(Raspberry pi's ARM here\) architecture [\#234](https://github.com/voxpupuli/puppet-consul/pull/234) ([gibre](https://github.com/gibre))
- Added custom init style "custom" [\#233](https://github.com/voxpupuli/puppet-consul/pull/233) ([sy-bee](https://github.com/sy-bee))
- lazily return nil when consul client isn't installed [\#227](https://github.com/voxpupuli/puppet-consul/pull/227) ([roobert](https://github.com/roobert))
- add NOFILE limit to systemd template [\#226](https://github.com/voxpupuli/puppet-consul/pull/226) ([eliranbz](https://github.com/eliranbz))
- Debian init script should depend on networking, resolution and syslog [\#222](https://github.com/voxpupuli/puppet-consul/pull/222) ([chrisboulton](https://github.com/chrisboulton))
- When reloading consul, use 127.0.0.1 as rpc\_addr when rpc\_addr was set to 0.0.0.0 [\#221](https://github.com/voxpupuli/puppet-consul/pull/221) ([danielbenzvi](https://github.com/danielbenzvi))
- Add hostname proprety for ACL operations, defaults to localhost, like before [\#219](https://github.com/voxpupuli/puppet-consul/pull/219) ([gozer](https://github.com/gozer))
- Consul Version Fact [\#209](https://github.com/voxpupuli/puppet-consul/pull/209) ([robrankin](https://github.com/robrankin))
- Set provider on consul service [\#125](https://github.com/voxpupuli/puppet-consul/pull/125) ([albustax](https://github.com/albustax))

## [v1.0.5](https://github.com/voxpupuli/puppet-consul/tree/v1.0.5) (2016-01-08)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.4...v1.0.5)

**Fixed bugs:**

- umask feature breaks CentOS init scripts [\#107](https://github.com/voxpupuli/puppet-consul/issues/107)

**Closed issues:**

- If $install\_method = 'url', won't upgrade consul [\#103](https://github.com/voxpupuli/puppet-consul/issues/103)

**Merged pull requests:**

- ACL fixes - idempotentcy and port bug. [\#214](https://github.com/voxpupuli/puppet-consul/pull/214) ([sigerber](https://github.com/sigerber))
- Fix port property [\#213](https://github.com/voxpupuli/puppet-consul/pull/213) ([afterwords](https://github.com/afterwords))
- Add support of OpenSuSE and SLED [\#212](https://github.com/voxpupuli/puppet-consul/pull/212) ([kscherer](https://github.com/kscherer))
- Fix web\_ui installation on Consul 0.6.0 and greater [\#208](https://github.com/voxpupuli/puppet-consul/pull/208) ([dbeckham](https://github.com/dbeckham))
- mitigate .to\_json segfaults on Ruby 1.8.7 [\#205](https://github.com/voxpupuli/puppet-consul/pull/205) ([duritong](https://github.com/duritong))

## [v1.0.4](https://github.com/voxpupuli/puppet-consul/tree/v1.0.4) (2015-12-15)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.3...v1.0.4)

**Merged pull requests:**

- Added support for TCP checks \(available in Consul 0.6.x\) [\#206](https://github.com/voxpupuli/puppet-consul/pull/206) ([hopperd](https://github.com/hopperd))

## [v1.0.3](https://github.com/voxpupuli/puppet-consul/tree/v1.0.3) (2015-12-10)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.2...v1.0.3)

**Closed issues:**

- Default mode on config.json and service files is too permissive [\#199](https://github.com/voxpupuli/puppet-consul/issues/199)
- Wrong number of arguments given [\#194](https://github.com/voxpupuli/puppet-consul/issues/194)
- metadata.json - needs at least 4.6.0 of stdlib [\#190](https://github.com/voxpupuli/puppet-consul/issues/190)
- Strange \(probably unnecessary\) behavior in sysv stop script [\#174](https://github.com/voxpupuli/puppet-consul/issues/174)

**Merged pull requests:**

- Updating staging file download to use the version and symlink [\#202](https://github.com/voxpupuli/puppet-consul/pull/202) ([hopperd](https://github.com/hopperd))
- Updated download\_urls used to be the new releases.hashicorp.com location [\#201](https://github.com/voxpupuli/puppet-consul/pull/201) ([hopperd](https://github.com/hopperd))
- parameterize config file mode [\#200](https://github.com/voxpupuli/puppet-consul/pull/200) ([aj-jester](https://github.com/aj-jester))
- Add parameter for setting port to custom acl type [\#197](https://github.com/voxpupuli/puppet-consul/pull/197) ([afterwords](https://github.com/afterwords))
- Allow ACL ID to be writeable [\#196](https://github.com/voxpupuli/puppet-consul/pull/196) ([robrankin](https://github.com/robrankin))
- need at least 4.6.0 of puppetlabs/stdlib  [\#191](https://github.com/voxpupuli/puppet-consul/pull/191) ([gdhbashton](https://github.com/gdhbashton))
- Remove management of unzip package [\#189](https://github.com/voxpupuli/puppet-consul/pull/189) ([danieldreier](https://github.com/danieldreier))
- consul init sysv: lower stop priority [\#188](https://github.com/voxpupuli/puppet-consul/pull/188) ([koendc](https://github.com/koendc))
- actually we want to escape / globally for filenames [\#186](https://github.com/voxpupuli/puppet-consul/pull/186) ([duritong](https://github.com/duritong))
- Fixed chuid / consul executed as root [\#183](https://github.com/voxpupuli/puppet-consul/pull/183) ([sw0x2A](https://github.com/sw0x2A))
- Rework sysv stop script to fix issues [\#181](https://github.com/voxpupuli/puppet-consul/pull/181) ([pforman](https://github.com/pforman))
- explicitly define ownership of config directory, installation breaks for hardened Linux boxes with default umask of 0077 - this fixes the problem [\#168](https://github.com/voxpupuli/puppet-consul/pull/168) ([proletaryo](https://github.com/proletaryo))

## [v1.0.2](https://github.com/voxpupuli/puppet-consul/tree/v1.0.2) (2015-09-05)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v1.0.0...v1.0.2)

**Closed issues:**

- Log rotation? [\#182](https://github.com/voxpupuli/puppet-consul/issues/182)
- Staging missing dependency on `Package['unzip']` [\#164](https://github.com/voxpupuli/puppet-consul/issues/164)
- Documentation [\#161](https://github.com/voxpupuli/puppet-consul/issues/161)
- Ruby 1.8 support [\#148](https://github.com/voxpupuli/puppet-consul/issues/148)
- GOMAXPROCS discarded by upstart init due to sudo's env\_reset option [\#126](https://github.com/voxpupuli/puppet-consul/issues/126)
- Module should have a CHANGELOG [\#122](https://github.com/voxpupuli/puppet-consul/issues/122)
- Debian: /var/run/consul/consul.pid user affinity inconsistent [\#120](https://github.com/voxpupuli/puppet-consul/issues/120)
- config\_hash converts strings to integers =\> breaks port mappings [\#119](https://github.com/voxpupuli/puppet-consul/issues/119)
- Invalid resource type staging::file [\#117](https://github.com/voxpupuli/puppet-consul/issues/117)
- Need to add -data-dir option to startup scripts. [\#115](https://github.com/voxpupuli/puppet-consul/issues/115)
- Meta stuff Not up to snuff [\#76](https://github.com/voxpupuli/puppet-consul/issues/76)
- Send SIGHUP to consul agent when new checks/services are detected [\#43](https://github.com/voxpupuli/puppet-consul/issues/43)
- Support consul-template [\#36](https://github.com/voxpupuli/puppet-consul/issues/36)

**Merged pull requests:**

- Update beaker tests + travis integration [\#180](https://github.com/voxpupuli/puppet-consul/pull/180) ([solarkennedy](https://github.com/solarkennedy))
- fix 'consul reload' on custom rpc port [\#179](https://github.com/voxpupuli/puppet-consul/pull/179) ([mdelagrange](https://github.com/mdelagrange))
- More rpc port support for debian/upstart [\#177](https://github.com/voxpupuli/puppet-consul/pull/177) ([solarkennedy](https://github.com/solarkennedy))
- Archlinux support [\#176](https://github.com/voxpupuli/puppet-consul/pull/176) ([vdloo](https://github.com/vdloo))
- pretty config \(that properly sorts\) [\#175](https://github.com/voxpupuli/puppet-consul/pull/175) ([aj-jester](https://github.com/aj-jester))
- prevent unnecessary consul restarts on puppet runs [\#173](https://github.com/voxpupuli/puppet-consul/pull/173) ([mdelagrange](https://github.com/mdelagrange))
- Add a check for $service\_ensure in reload\_service [\#172](https://github.com/voxpupuli/puppet-consul/pull/172) ([pforman](https://github.com/pforman))
- deep\_merge to support nested objects [\#171](https://github.com/voxpupuli/puppet-consul/pull/171) ([aj-jester](https://github.com/aj-jester))
- parameterize restart on change for the main config [\#169](https://github.com/voxpupuli/puppet-consul/pull/169) ([aj-jester](https://github.com/aj-jester))
- unzip depedency for staging [\#166](https://github.com/voxpupuli/puppet-consul/pull/166) ([aj-jester](https://github.com/aj-jester))
- Adding support for Ubuntu 15.04 [\#163](https://github.com/voxpupuli/puppet-consul/pull/163) ([asasfu](https://github.com/asasfu))
- Ensure all network interfaces are up before starting in upstart config [\#162](https://github.com/voxpupuli/puppet-consul/pull/162) ([jbarbuto](https://github.com/jbarbuto))
- UI dir symlink should depend on the dist existing [\#158](https://github.com/voxpupuli/puppet-consul/pull/158) ([jsok](https://github.com/jsok))
- remove string casting to int [\#157](https://github.com/voxpupuli/puppet-consul/pull/157) ([aj-jester](https://github.com/aj-jester))
- convert quoted integers to int object [\#156](https://github.com/voxpupuli/puppet-consul/pull/156) ([aj-jester](https://github.com/aj-jester))
- Update the gemfile, hopefully to something beaker and puppet-rspec can tolerate [\#154](https://github.com/voxpupuli/puppet-consul/pull/154) ([solarkennedy](https://github.com/solarkennedy))
- travis update [\#153](https://github.com/voxpupuli/puppet-consul/pull/153) ([jlambert121](https://github.com/jlambert121))
- reload on service, checks and watch changes [\#152](https://github.com/voxpupuli/puppet-consul/pull/152) ([aj-jester](https://github.com/aj-jester))
- acl token support for services and checks [\#151](https://github.com/voxpupuli/puppet-consul/pull/151) ([aj-jester](https://github.com/aj-jester))
- Modify consul\_validate\_checks to work with ruby 1.8 [\#149](https://github.com/voxpupuli/puppet-consul/pull/149) ([solarnz](https://github.com/solarnz))
- Adding groups parameter to user definition [\#147](https://github.com/voxpupuli/puppet-consul/pull/147) ([robrankin](https://github.com/robrankin))
- upstart: Agents should gracefully leave cluster on stop [\#146](https://github.com/voxpupuli/puppet-consul/pull/146) ([jsok](https://github.com/jsok))
- explicitly set depedencies for package install [\#145](https://github.com/voxpupuli/puppet-consul/pull/145) ([jlambert121](https://github.com/jlambert121))
- Use strict vars all the time, and future parser for later versions [\#144](https://github.com/voxpupuli/puppet-consul/pull/144) ([solarkennedy](https://github.com/solarkennedy))
- add puppet 4 testing to travis [\#143](https://github.com/voxpupuli/puppet-consul/pull/143) ([jlambert121](https://github.com/jlambert121))
- create user/group as system accounts [\#142](https://github.com/voxpupuli/puppet-consul/pull/142) ([jlambert121](https://github.com/jlambert121))
- correct links for consul template [\#140](https://github.com/voxpupuli/puppet-consul/pull/140) ([jlambert121](https://github.com/jlambert121))
- compatibiliy fix: ensure variables are defined [\#139](https://github.com/voxpupuli/puppet-consul/pull/139) ([mklette](https://github.com/mklette))
- Pass ensure to service definition file [\#138](https://github.com/voxpupuli/puppet-consul/pull/138) ([mklette](https://github.com/mklette))
- Fix debian init [\#137](https://github.com/voxpupuli/puppet-consul/pull/137) ([dizzythinks](https://github.com/dizzythinks))
- update default consul version [\#136](https://github.com/voxpupuli/puppet-consul/pull/136) ([jlambert121](https://github.com/jlambert121))
- Make consul::install optional [\#135](https://github.com/voxpupuli/puppet-consul/pull/135) ([potto007](https://github.com/potto007))
- Add an exec to daemon-reload systemctl when the unit-file changes [\#134](https://github.com/voxpupuli/puppet-consul/pull/134) ([robrankin](https://github.com/robrankin))
- Fix issue \#129 - https://github.com/solarkennedy/puppet-consul/issues/129 [\#133](https://github.com/voxpupuli/puppet-consul/pull/133) ([potto007](https://github.com/potto007))
- Escape the ID & make fixtures useable more widely [\#132](https://github.com/voxpupuli/puppet-consul/pull/132) ([duritong](https://github.com/duritong))
- Change name of File\['config.json'\] to File\['consul config.json'\] [\#131](https://github.com/voxpupuli/puppet-consul/pull/131) ([EvanKrall](https://github.com/EvanKrall))
- Switch to using start-stop-daemon for consul upstart init script [\#130](https://github.com/voxpupuli/puppet-consul/pull/130) ([bdellegrazie](https://github.com/bdellegrazie))
- Supply optional token for ACL changes [\#128](https://github.com/voxpupuli/puppet-consul/pull/128) ([mdelagrange](https://github.com/mdelagrange))
- Fix pidfile handling on Debian [\#121](https://github.com/voxpupuli/puppet-consul/pull/121) ([weitzj](https://github.com/weitzj))

## [v1.0.0](https://github.com/voxpupuli/puppet-consul/tree/v1.0.0) (2015-04-30)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v0.4.6...v1.0.0)

**Closed issues:**

- README for consul::service is out of date [\#110](https://github.com/voxpupuli/puppet-consul/issues/110)
- delete\_undef\_values required stdlib 4.2.0, dependency not set properly [\#109](https://github.com/voxpupuli/puppet-consul/issues/109)
- init script doesn't have data-dir \(0.5.0\) [\#100](https://github.com/voxpupuli/puppet-consul/issues/100)
- passingonly needs to be a boolean for watch type [\#97](https://github.com/voxpupuli/puppet-consul/issues/97)
- Dependency cycle using consul::services [\#90](https://github.com/voxpupuli/puppet-consul/issues/90)
- consul should not 'leave' for init script 'stop' action [\#85](https://github.com/voxpupuli/puppet-consul/issues/85)
- Cycling dependancy in Hiera-based config [\#81](https://github.com/voxpupuli/puppet-consul/issues/81)
- Support for Consul 0.5.0 and multiple check configuration [\#73](https://github.com/voxpupuli/puppet-consul/issues/73)
- Path to /home/kyle is hard coded, somewhere [\#65](https://github.com/voxpupuli/puppet-consul/issues/65)

**Merged pull requests:**

- Debian 8.0+ uses systemd [\#113](https://github.com/voxpupuli/puppet-consul/pull/113) ([CyBeRoni](https://github.com/CyBeRoni))
- Update README, ensure passingonly is a bool [\#112](https://github.com/voxpupuli/puppet-consul/pull/112) ([zxjinn](https://github.com/zxjinn))
- Update puppetlabs-stdlib dependency to 4.2.0 for the delete\_undef\_values function [\#111](https://github.com/voxpupuli/puppet-consul/pull/111) ([zxjinn](https://github.com/zxjinn))
- Revert "Allow setting of the umask for the consul daemon." [\#108](https://github.com/voxpupuli/puppet-consul/pull/108) ([sjoeboo](https://github.com/sjoeboo))
- Allow setting of the umask for the consul daemon. [\#106](https://github.com/voxpupuli/puppet-consul/pull/106) ([EvanKrall](https://github.com/EvanKrall))
- Respect user and group in launchd. [\#105](https://github.com/voxpupuli/puppet-consul/pull/105) ([EvanKrall](https://github.com/EvanKrall))
- Anchor the consul install/config/run\_service classes [\#102](https://github.com/voxpupuli/puppet-consul/pull/102) ([koendc](https://github.com/koendc))
- Added support for consul 0.5.0 features: [\#99](https://github.com/voxpupuli/puppet-consul/pull/99) ([hopperd](https://github.com/hopperd))
- make module work with future parser [\#92](https://github.com/voxpupuli/puppet-consul/pull/92) ([duritong](https://github.com/duritong))
- Add consul\_acl type and provider [\#91](https://github.com/voxpupuli/puppet-consul/pull/91) ([michaeltchapman](https://github.com/michaeltchapman))
- Consul expects prefix rather than keyprefix in watch config [\#89](https://github.com/voxpupuli/puppet-consul/pull/89) ([codesplicer](https://github.com/codesplicer))
- Expose id parameter for service definitions [\#88](https://github.com/voxpupuli/puppet-consul/pull/88) ([codesplicer](https://github.com/codesplicer))
- sysv & debian init updates to kill or leave [\#87](https://github.com/voxpupuli/puppet-consul/pull/87) ([runswithd6s](https://github.com/runswithd6s))
- Updated the params for OracleLinux Support [\#84](https://github.com/voxpupuli/puppet-consul/pull/84) ([MarsuperMammal](https://github.com/MarsuperMammal))
- Fixes \#81 bugfix cycle dependency when specifying a service [\#82](https://github.com/voxpupuli/puppet-consul/pull/82) ([tayzlor](https://github.com/tayzlor))
- Added compatibility for Scientific Linux [\#78](https://github.com/voxpupuli/puppet-consul/pull/78) ([tracyde](https://github.com/tracyde))
- More lint fixes [\#77](https://github.com/voxpupuli/puppet-consul/pull/77) ([solarkennedy](https://github.com/solarkennedy))
- Support for Amazon OS [\#68](https://github.com/voxpupuli/puppet-consul/pull/68) ([dcoxall](https://github.com/dcoxall))

## [v0.4.6](https://github.com/voxpupuli/puppet-consul/tree/v0.4.6) (2015-01-23)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v0.4.5...v0.4.6)

**Closed issues:**

- Consul init scripts sometimes not installed in the correct order [\#74](https://github.com/voxpupuli/puppet-consul/issues/74)

**Merged pull requests:**

- Move init script to config.pp to ensure it gets set AFTER the package gets installed [\#75](https://github.com/voxpupuli/puppet-consul/pull/75) ([tayzlor](https://github.com/tayzlor))
- Add support for providing watches/checks/services via hiera  [\#72](https://github.com/voxpupuli/puppet-consul/pull/72) ([tayzlor](https://github.com/tayzlor))
- Fix Puppet 3.7.3 giving evaluation error in run\_service.pp [\#71](https://github.com/voxpupuli/puppet-consul/pull/71) ([tayzlor](https://github.com/tayzlor))
- Update install.pp [\#69](https://github.com/voxpupuli/puppet-consul/pull/69) ([ianlunam](https://github.com/ianlunam))
- Adding ability to disable managing of the service [\#67](https://github.com/voxpupuli/puppet-consul/pull/67) ([sedan07](https://github.com/sedan07))
- Some linting fixes and resolves joining wan not actually joining the wan [\#66](https://github.com/voxpupuli/puppet-consul/pull/66) ([justicel](https://github.com/justicel))
- Better OS support for init\_style [\#63](https://github.com/voxpupuli/puppet-consul/pull/63) ([nukemberg](https://github.com/nukemberg))

## [v0.4.5](https://github.com/voxpupuli/puppet-consul/tree/v0.4.5) (2015-01-16)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v0.4.4...v0.4.5)

**Merged pull requests:**

- Adding "status" to the debian init script [\#64](https://github.com/voxpupuli/puppet-consul/pull/64) ([paulhamby](https://github.com/paulhamby))

## [v0.4.4](https://github.com/voxpupuli/puppet-consul/tree/v0.4.4) (2015-01-16)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v0.4.2...v0.4.4)

**Closed issues:**

- Allow Consul clients to join cluster [\#61](https://github.com/voxpupuli/puppet-consul/issues/61)
- new function sorted\_json does not work if keys are set to undef [\#59](https://github.com/voxpupuli/puppet-consul/issues/59)
- Bump to hashicorp/consul  GitHub version e9615c50e6 [\#58](https://github.com/voxpupuli/puppet-consul/issues/58)
- cannot generate right retry\_join string [\#57](https://github.com/voxpupuli/puppet-consul/issues/57)
- join\_cluster not working on agents [\#56](https://github.com/voxpupuli/puppet-consul/issues/56)
- Multiple consul::service with same name causes ArgumentError [\#46](https://github.com/voxpupuli/puppet-consul/issues/46)
- service definition file will be changed frequently [\#45](https://github.com/voxpupuli/puppet-consul/issues/45)
- cut a new release? [\#41](https://github.com/voxpupuli/puppet-consul/issues/41)
- join\_cluster doesn't seem to work in some cases [\#31](https://github.com/voxpupuli/puppet-consul/issues/31)
- Tests need ruby \>= 1.9.2 [\#7](https://github.com/voxpupuli/puppet-consul/issues/7)

**Merged pull requests:**

- Allow hash keys to be set to undef [\#60](https://github.com/voxpupuli/puppet-consul/pull/60) ([bodepd](https://github.com/bodepd))
- Add config\_defaults hash parameter [\#54](https://github.com/voxpupuli/puppet-consul/pull/54) ([michaeltchapman](https://github.com/michaeltchapman))
- Make init\_style can be disabled [\#53](https://github.com/voxpupuli/puppet-consul/pull/53) ([tiewei](https://github.com/tiewei))
- Make rake spec running [\#52](https://github.com/voxpupuli/puppet-consul/pull/52) ([tiewei](https://github.com/tiewei))
- use versioncmp to compare versions [\#49](https://github.com/voxpupuli/puppet-consul/pull/49) ([jfroche](https://github.com/jfroche))
- Allow overriding a service's name [\#47](https://github.com/voxpupuli/puppet-consul/pull/47) ([jsok](https://github.com/jsok))
- Make puppet-consul install on OS X [\#44](https://github.com/voxpupuli/puppet-consul/pull/44) ([EvanKrall](https://github.com/EvanKrall))

## [v0.4.2](https://github.com/voxpupuli/puppet-consul/tree/v0.4.2) (2014-10-28)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v0.4.1...v0.4.2)

## [v0.4.1](https://github.com/voxpupuli/puppet-consul/tree/v0.4.1) (2014-10-28)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/v0.3.0...v0.4.1)

**Closed issues:**

- Add support for joining multiple datacenters [\#34](https://github.com/voxpupuli/puppet-consul/issues/34)
- Configuring consul client nodes [\#26](https://github.com/voxpupuli/puppet-consul/issues/26)
- Add support for the new "watch" resource exposed in Consul 0.4.0 [\#23](https://github.com/voxpupuli/puppet-consul/issues/23)
- Install ui broken ?  [\#19](https://github.com/voxpupuli/puppet-consul/issues/19)

**Merged pull requests:**

- Set default of GOMAXPROCS=2 for SLES [\#40](https://github.com/voxpupuli/puppet-consul/pull/40) ([tehranian](https://github.com/tehranian))
- Fix the GOMAXPROCS warning for Upstart-based systems [\#39](https://github.com/voxpupuli/puppet-consul/pull/39) ([tehranian](https://github.com/tehranian))
- bump to version 0.4.1 [\#38](https://github.com/voxpupuli/puppet-consul/pull/38) ([kennyg](https://github.com/kennyg))
- Add sysconfig support for sysv [\#37](https://github.com/voxpupuli/puppet-consul/pull/37) ([dblessing](https://github.com/dblessing))
- Add join\_wan feature [\#35](https://github.com/voxpupuli/puppet-consul/pull/35) ([dblessing](https://github.com/dblessing))
- Version bump; Download Consul 0.4.0 [\#33](https://github.com/voxpupuli/puppet-consul/pull/33) ([tehranian](https://github.com/tehranian))
- Add support for SLES [\#32](https://github.com/voxpupuli/puppet-consul/pull/32) ([tehranian](https://github.com/tehranian))
- Add option to purge config dir [\#30](https://github.com/voxpupuli/puppet-consul/pull/30) ([sorenisanerd](https://github.com/sorenisanerd))
- Changed cluster join code [\#29](https://github.com/voxpupuli/puppet-consul/pull/29) ([hkumarmk](https://github.com/hkumarmk))
- \(retry\) Service Definition documentation and fix [\#28](https://github.com/voxpupuli/puppet-consul/pull/28) ([benschw](https://github.com/benschw))
- Adding in explicit support for "watches" [\#24](https://github.com/voxpupuli/puppet-consul/pull/24) ([jrnt30](https://github.com/jrnt30))
- Added join\_cluster param to have consul join a cluster after \(re\)starting service [\#21](https://github.com/voxpupuli/puppet-consul/pull/21) ([tylerwalts](https://github.com/tylerwalts))
- Fixing gui\_package install [\#20](https://github.com/voxpupuli/puppet-consul/pull/20) ([KrisBuytaert](https://github.com/KrisBuytaert))
- Added upstart link for old init.d functionality on upstart jobs [\#18](https://github.com/voxpupuli/puppet-consul/pull/18) ([lynxman](https://github.com/lynxman))
- bump to version 0.3.1 [\#17](https://github.com/voxpupuli/puppet-consul/pull/17) ([kennyg](https://github.com/kennyg))
- Install the consul web ui [\#15](https://github.com/voxpupuli/puppet-consul/pull/15) ([croomes](https://github.com/croomes))
- Adds systemd support [\#14](https://github.com/voxpupuli/puppet-consul/pull/14) ([croomes](https://github.com/croomes))
- Update CONTRIBUTORS [\#12](https://github.com/voxpupuli/puppet-consul/pull/12) ([kennyg](https://github.com/kennyg))
- bumped to version 0.3.0 [\#11](https://github.com/voxpupuli/puppet-consul/pull/11) ([kennyg](https://github.com/kennyg))

## [v0.3.0](https://github.com/voxpupuli/puppet-consul/tree/v0.3.0) (2014-06-20)

[Full Changelog](https://github.com/voxpupuli/puppet-consul/compare/31fcf01beb754dfa7884ff34eea1313f71593b26...v0.3.0)

**Closed issues:**

- Upstart script does not work on Lucid [\#5](https://github.com/voxpupuli/puppet-consul/issues/5)
- Debian support [\#1](https://github.com/voxpupuli/puppet-consul/issues/1)

**Merged pull requests:**

- Add extra\_options parameter, to allow extra arguments to the consul agent [\#9](https://github.com/voxpupuli/puppet-consul/pull/9) ([EvanKrall](https://github.com/EvanKrall))
- Define consul::service and consul::check types [\#8](https://github.com/voxpupuli/puppet-consul/pull/8) ([EvanKrall](https://github.com/EvanKrall))
- Convert from setuid/setgid to sudo for Lucid support. Allow for group management. [\#6](https://github.com/voxpupuli/puppet-consul/pull/6) ([EvanKrall](https://github.com/EvanKrall))
- Make download actually work [\#3](https://github.com/voxpupuli/puppet-consul/pull/3) ([nberlee](https://github.com/nberlee))
- Make example config parseable [\#2](https://github.com/voxpupuli/puppet-consul/pull/2) ([nberlee](https://github.com/nberlee))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
