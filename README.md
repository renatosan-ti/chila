# chila

### Definition
**chila** is a CLI frontend for [Storj*](https://www.storj.io/) written in **Ruby**. Its only external dependency is the `uplink` program, provided by the company.

> Storj* is an alternative to cloud storage platforms like those offered by Amazon or Google

### Example
The standard output of the `uplink` command is similar to this:
```
$ uplink ls
CREATED                NAME
2022-05-31 10:37:49    aee
2022-03-22 16:37:52    coisas
2022-03-30 22:57:17    dale
2022-03-24 12:58:14    fotos
2022-05-23 21:54:17    maria
```

And **chila** looks like this:

![image](https://user-images.githubusercontent.com/98054462/177184806-a6855062-625c-481d-a626-7b7a152c2be1.png)

Cool, right?

### Install
> Before use this app, please create an account and first access clicking by [this link](https://www.storj.io/)

1. Clone this repository
2. `chmod +x chila`
3. `./chila`
4. Enjoy

### Development
**chila** is under development (helps to practice Ruby language). So bugs are expected.

#### What is currently working?
- [x] Create buckets
- [x] List buckets
- [x] Remove buckets
#### What is not (yet) currently working?
- [ ] Move (or rename) buckets
- [ ] List objects in buckets
- [ ] Move (or rename) buckets
