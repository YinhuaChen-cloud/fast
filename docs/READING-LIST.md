# Useful Reading list for s2n-tls


## Books

* [Bulletproof SSL and TLS](http://www.amazon.com/Bulletproof-SSL-TLS-Understanding-Applications/dp/1907117040/) - great book by Ivan Ristic.
* [Implementing SSL / TLS using Cryptography and PKI](http://www.amazon.com/Implementing-SSL-TLS-Using-Cryptography/dp/0470920416/) - by Joshua Davies.
* [Introduction to Modern Cryptography, 2nd ed](http://www.amazon.com/Introduction-Cryptography-Chapman-Network-Security/dp/1466570261/) - Katz and Lindell

## RFCs and specifications relating to TLS/SSL

* [SSLv2](http://www-archive.mozilla.org/projects/security/pki/nss/ssl/draft02.html)
* [SSLv3](https://tools.ietf.org/html/rfc6101)
* [TLS 1.0](https://tools.ietf.org/html/rfc2246)
* [TLS 1.1](https://tools.ietf.org/html/rfc4346)
* [TLS 1.2](https://tools.ietf.org/html/rfc5246)
* [AES GCM for TLS](https://tools.ietf.org/html/rfc5288)
* [ECC cipher suites for TLS](https://tools.ietf.org/html/rfc4492)
* [TLS extensions](https://tools.ietf.org/html/rfc6066)
* [Application-Layer Protocol Negotiation Extension](https://tools.ietf.org/html/rfc7301)
* [TLS 1.3 draft specification](https://github.com/tlswg/tls13-spec)
* [SSLv3 is deprecated](https://tools.ietf.org/html/rfc7568)
* [Certificate Transparency](https://tools.ietf.org/html/rfc6962)

## ASN.1 and X509

* [X.509 PKI](https://tools.ietf.org/html/rfc4210)
* [X.509 PKI and CRLs](https://tools.ietf.org/html/rfc5280)
* [Layman's Guide to ASN.1](http://luca.ntop.org/Teaching/Appunti/asn1.html)

## Interesting implementations

* [MiTLS](http://www.mitls.org/wsgi/home) , and [TLS Attacks](http://www.mitls.org/wsgi/tls-attacks) in particular. 
* [GoTLS](http://golang.org/pkg/crypto/tls/) - TLS as implemented in the Go programming language
* [OpenSSL](https://www.openssl.org/) - ubiquitous and reference implementation
* [LibreSSL](http://www.libressl.org/) - fork of OpenSSL maintained by a team from OpenBSD
* [BoringSSL](https://boringssl.googlesource.com/boringssl/) - fork of OpenSSL maintained by Google Security team
* [NSS](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS) - maintained by Mozilla, used by several browsers
* [AWS LibCrypto](https://github.com/awslabs/aws-lc) - Fork of BoringSSL maintained by Amazon

## Mailing lists and forums

* [IETF TLS Working Group](https://datatracker.ietf.org/wg/tls/charter/)
* [IETF CRFG](http://www.ietf.org/mail-archive/web/cfrg/current/maillist.html) 

## Videos and tutorials

* [AWS re:Invent 2014: SSL with Amazon Web Services](https://www.youtube.com/watch?v=8AODa_AazY4) - nuts and bolts overview of SSL/TLS
* [AWS re:Invent 2016: Amazon s2n: Cryptography and Open Source at AWS](https://www.youtube.com/watch?v=APhTOQ9eeI0)
* [AWS re:Invent 2016: Encryption: It Was the Best of Controls, It Was the Worst of Controls](https://www.youtube.com/watch?v=zmMpgbIhCpw)
* [AWS re:Invent 2016: Automated Formal Reasoning About AWS Systems](https://www.youtube.com/watch?v=U40bWY6oVtU)
* [AWS re:Invent 2017: The AWS Philosophy of Security](https://www.youtube.com/watch?v=KJiCfPXOW-U)
* [AWS re:Inforce 2019: Cryptography in the Next Cycle](https://www.youtube.com/watch?v=iBUReOA8s7Y)
* [AWS re:Invent 2019: It’s always day zero: Working on open source and security](https://www.youtube.com/watch?v=3Me_eapZ1bI)
* [AWS re:Invent 2019: Leadership session: AWS security](https://youtu.be/oam8FDNJhbE?t=2481)
* [AWS re:Invent 2020: Building post-quantum cryptography for the cloud](https://www.youtube.com/watch?v=_GSDUXPpSgc)
* [An AWS approach to post-quantum cryptography](https://www.youtube.com/watch?v=ixn3A7htBnw)
* Illustrated Walkthrough of the entire TLS 1.2 Handshake: https://tls12.ulfheim.net/
* Illustrated Walkthrough of the entire TLS 1.3 Handshake: https://tls13.ulfheim.net/

## Miscellaneous

* [NIST SP 800-90A](http://csrc.nist.gov/publications/nistpubs/800-90A/SP800-90A.pdf)
* [DJBs crypto page](http://cr.yp.to/crypto.html)
* [DJBs entropy attacks](http://blog.cr.yp.to/20140205-entropy.html)
* [NaCL](http://nacl.cr.yp.to/) and [libsodium](https://github.com/jedisct1/libsodium)
* [spiped](http://www.tarsnap.com/spiped.html) 
