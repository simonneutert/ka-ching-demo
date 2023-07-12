# ka-ching Demo repository<!-- omit in toc -->

This project has the purpose to demonstrate what can be easily achieved with:

- [ka-ching-backend](https://github.com/simonneutert/ka-ching-backend)
- [ka-ching-client](https://github.com/simonneutert/ka-ching-client)

This project serves as a starting point for users interested in building their own customized cash register systems. It is important to note that this demo represents just one of the countless ways to utilize the backend and client components provided. By exploring this project, you will gain insights into the core features and workflows that power a modern cash register system.

While this demo project provides a solid foundation, we encourage you to customize and adapt it to suit your specific requirements. Consider it a flexible template, ready to be tailored to your unique business needs, industry, and user preferences. By leveraging the code and concepts presented here, you can create a cash register system that aligns perfectly with your vision.

Whether you are a developer seeking inspiration or a business owner exploring the possibilities, we believe that this demo project will inspire you to craft your ideal cash register system. It is just the tip of the iceberg, representing one of the million potential directions you can take.

So, dive in, explore the code, and embark on your journey of building a cash register system that suits your aspirations. I am excited to see the innovative applications you develop using this project as your starting point. Happy coding!

---

- [Screenshots](#screenshots)
- [Features](#features)
- [Todos](#todos)
- [Local development environment (with Docker)](#local-development-environment-with-docker)
  - [Reset the database](#reset-the-database)

## Screenshots

<details>
  <summary>Click to expand</summary>

![Screenshot of the demo application - landing page](./public/screenshots/1.png)

> ☝️ The landing page of the demo application.

---

![Screenshot of the demo application - select or create a tenant](./public/screenshots/2.png)

> ☝️ The `/tenants` page of the demo application, where you can select or create a tenant.

---

![Screenshot of the demo application - tenant created notification](./public/screenshots/3.png)

> ☝️ A tenant has been created and the user is notified about it.

---

![Screenshot of the demo application - action page after login for deposit, withdraw and lockings](./public/screenshots/4.png)

> ☝️ The `/bookings` page of the demo application, where you can deposit, withdraw and lock the cash register. Below you will see the current active bookings, be it a deposit or a withdrawal.

---

![Screenshot of the demo application - action page with deposit selected](./public/screenshots/5.png)

> ☝️ The `/bookings` page of the demo application with the deposit form selected.

---

![Screenshot of the demo application - action page with deposit selected](./public/screenshots/6.png)

> ☝️ You can see the saldo has changed after the deposit has been submitted.

---

![Screenshot of the demo application - action page with deposit selected](./public/screenshots/7.png)

> ☝️ Here an attempt to withdraw more money than is available in the cash register is about to be made.

---

![Screenshot of the demo application - action page with deposit selected](./public/screenshots/8.png)

> ☝️ Notifying the user that the withdrawal is not possible. Below you can see the current active bookings, be it a deposit or a withdrawal. Current unlocked bookings can be deleted.

</details>

## Features

- [x] Deposit money into the cash register
- [x] Withdraw money from the cash register
- [x] Show the current balance of the cash register
- [x] Lock the cash register
- [x] Unlock last lock of the cash register 🎉
- [x] Show AuditLogs of current year
- [x] Prohibit double clicks / double submission (htmx throttle ftw)
- [x] Show notifications/toasts on errors
  - [x] withdraw
  - [x] deposit
- [x] Delete a Booking in the current activeregister
- [ ] Show notifications/toasts on errors
  - [ ] locking
  - [ ] deletion of a booking

## Todos

For features the API backend and client bring, but aren't showcased in this demo, yet.

- [ ] Provide a way to navigate through the AuditLogs
- [ ] Detail view of a single AuditLog
- [ ] Detail view of a single Lock
- [ ] Detail view of a single Booking

<details>
  <summary>Roadmap / Planned</summary>

### Not yet coded features in demo, but the backend/client provides them (planned)<!-- omit in toc -->

- [ ] pagination through Lockings
- [ ] Show AuditLogs of a year of choice
- [ ] multi-tenant support
  - [ ] change the tenant
  - [ ] create a new tenant
  - [ ] reset a tenant
- [ ] multi-currency support
- [ ] Reset everything every 30min

### Bonus (I may or may not code it for this demo)<!-- omit in toc -->

- [ ] csv export of Lockings
- [ ] csv export of AuditLogs

</details>

## Local development environment (with Docker)

1. Clone/Download this repository
2. Run `docker-compose pull` in the root directory of this repository
3. Run `docker-compose build` in the root directory of this repository
4. Now get everything up and running with `bin/dev`
5. `ka-ching-backend` is now running on `localhost:4567`

Check out what's in the **/bin** folder 😉

### Reset the database

`bin/reset` and when finished `bin/dev` to get everything up and running again 🤷‍♂️
