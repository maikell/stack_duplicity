Background material
===================

* https://www.transip.nl/vragen/756-stack-externe-voor-mijn-gebruiken/ (NL)
* https://help.ubuntu.com/community/DuplicityBackupHowto

Introduction
=============

TransIP offers a free STACK (online storage) of 1TB. The stack can be mounted as webdav. Although webdav is not the fasted protocol, it works.
TransIP does not want to disclose about when your files are decrypted at their side due to 'security reasons'.
That's the reason why we use Duplicity and GPG. In abstract it does the following: It mounts the storage as webdav, comparing the diff's
of the last backup and than proceeds to push new diff's to the stack if needed. The GPG private and public key
resides below the /root. The script runs as `root`. This can be changed with some simple modifications, although you will need root to setup
the backup scheme.



1. Install packages
===================

```
[root@local /]# apt-get install davfs2 duplicity haveged -y # For debian/ubuntu
[root@local /]# yum install davfs2 duplicity haveged -y # For redhat/centos
```

```
[root@local /]# systemctl start haveged; systemctl enable haveged
[root@local /]# mkdir -p /srv/stack
```

* `Haveged` is needed to generate enough (and fast) entropy. This service can be removed after generation of the GPG keys.


2. Add login credentails of STACK
=================================

Add a new line and insert your credentials:
```
https://<stackname>.stackstorage.com/remote.php/webdav/ <username> <passphrase>
```

3. Edit fstab
=============

```
[root@local /]# vi /etc/fstab
https://<stackname>.stackstorage.com/webdav /srv/stack davfs user,rw,noauto 0 0
```

Never, ever use automount. It's not needed and will break the boot process when the stack will be offline.

4. Check mountpoint
===================
```
[root@local /]# mount /srv/stack
```

5. Generate GPG keys (Each vm different and as user root(!))
=========================================================

```
[root@local /]# gpg --gen-key
(1) RSA and RSA (default)
4096 bits
0 = key does not expire
Realname = Stackkey <servername>
mailadres = root@<servername>
Comment = Stack backup
(O)kay
password (and add password to secrets file(!)) minimal 20 characters
```

6. Duplicity Create script + config
===================================

```
[root@local /]# mkdir /etc/duplicity
[root@local /]# vi backup_duplicity
```

* Paste duplicity script
* Edit secret id (from stdout of GPG generation) , like 7ABD40E6 (last hash to be found in output)`
* Edit servername variable
* Add executable permissions: `chmod +x backup_duplicity`

`[root@local /]# vi /etc/duplicity/.passphrase`

And paste: `PASSPHRASE="<PASSWORD>"`

```
[root@local /]# chmod 600 /etc/duplicity/.passphrase # <-- important!
```

6.1  Adding directories that will be backuped and remove delta's after an amount of time
========================================================================================

Example:
#/etc
```
[root@local /]# $(which duplicity) --encrypt-key $KEYID $LOGFILE --num-retries 3 --sign-key $KEYID /etc file:///$MOUNTDIR/$SERVERNAME/etc`
```

```
[root@local /]#$(which duplicity) remove-all-but-n-full $INCREMENTS --force file:///$MOUNTDIR/$SERVERNAME/etc`
```

6.2: Adding directory structure in stack mount
===============================================

```
[root@local /]# mount /srv/stack
```

```
[root@local /]# mkdir -p /srv/stack/$servername/$directory
```

7.0 Running the script and always verify if it backups as wished!
=================================================================

1. `[root@local /]# /etc/dupliciy/backup_script`
2. `[root@local /]# mount /srv/stack`
3. `[root@local /]# duplicity list-current-files file:///srv/stack/<servername>/etc`

Changelog
=========

* 2016-04-27: Clearified some parts and fixed spelling mistakes
* 2016-04-27: Fixed layout of readme.md
* 2016-04-27: First publication
