---
{
  "aliases": ["/writing/how-to-chroot-a-user-in-ubuntu-1204"],
  "slug": "how-to-chroot-a-user-in-ubuntu-1204",
  "date": "2012-10-16",
  "title": "How to chroot a user in Ubuntu 12.04",
  "description": "Allowing external parties to sFTP securely",
  "tags": ["ubuntu"],
}
---

External parties often need to upload data to your application. Sadly, most ask
for a FTP server. Push back against this and suggest they use sFTP.

This article explains how to set-up a chroot-ed user in Ubuntu 12.04 so that an
external party can upload data to your application securely.

This is mainly for my own reference.

### User set-up

Create user with a dummy shell:

```bash
adduser --shell=/bin/false barry
```

and alter the ownership and permissions of their home folder:

```bash
chown root:barry /home/barry
chmod 755 /home/barry
```

Now create a folder to upload to:

```bash
mkdir /home/barry/uploads
chown barry:barry /home/barry/uploads
chmod 755 /home/barry/uploads
```

### SSH config

Edit `/etc/ssh/sshd_config` and comment out the line:

```bash
Subsystem sftp /usr/lib/openssh/sftp-server
```

and add the following at the bottom of the file:

```bash
Subsystem sftp internal-sftp
Match User barry
    ChrootDirectory %h
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTCPForwarding no
```

then restart SSH:

```bash
/etc/init.d/ssh restart
```

The new user should now be able to sFTP.

### Further reading

- [How to set up and chroot SFTP users with OpenSSH 5.1p1 in Ubuntu 8.10](http://www.ericstockwell.com/?p=54)
