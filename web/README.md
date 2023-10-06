## if using mysql 
change all the postgresql in prisma setting to mysql, then
might need to delete all the migration forlder,

$ npx prisma migrate dev --name init

## DEBUG
/api/login POST
Error: Password string too short (min 32 characters required)

-->
.env
make IRON_SECRET longer than 32 characters



# web

Full-stack application to demonstrate Webauthn authentication method

## Install

```
pnpm -r i --frozen-lockfile
```

## Develop

First, you have to deploy database. Here's to develop and deploy locally with [Docker compose](https://docs.docker.com/compose/)

```
cp .env.example .env
docker-compose up -d
pnpm prisma migrate deploy
pnpm prisma generate
```

Then, start SvelteKit application with

```
pnpm dev
```
