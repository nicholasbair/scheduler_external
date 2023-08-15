# SchedulerExternal

## Use case
Demonstrate the usage of the Nylas scheduler (`confirmation_method` = `external`) with a payment workflow.

## What is it really?
Imagine you are using the Nylas scheduler to book meetings with clients, but also need to collect payment from clients before you tie up your calendar (e.g. consulting business, etc.).  You could certainly use the out of the box scheduler and insert your payment workflow at the end of the booking flow, but then your calendar would be booked before the client pays for your time.  One option for addressing this is to leverage scheduler `confirmation_method` = `external`, which allows your application to take over the event creation process and insert whatever other workflows into the process as you see fit.

## Features
- Authentication for calendar integrations powered by Nylas
- Create/update scheduling pages
- Assign a cost to your scheduler pages
- The booking process is hosted in an iframe, so the scheduling user stays within the app
- Booking users are redirected to a payment workflow powered by Stripe
- During the payment workflow, the organizer's calendar is blocked with an event with a TTL
- After the payment is confirmed, the user is invited to the meeting
- Whitelabeled cancellation/rescheduling links

## What's missing?
My initial focus here was on the happy path, so the app is missing:
- Tests
- Styling
- Error handling with end user consumable error messages

## Running locally
- Clone the repo
- CD into the directory
- Make sure you have Postgres installed and running
- Set environment variables: `CLOAK_KEY`, `NYLAS_CLIENT_ID`, `NYLAS_CLIENT_SECRET`, `STRIPE_SECRET_KEY`
- Set your authentication redirect in the Nylas dashboard `#{your_base_url}/integrations/callback`
- Run `mix setup` to install and setup dependencies
- Start Phoenix server with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- Now you can visit `localhost:4000` from your browser.
- With the server running, setup your webhook URL in the Nylas dashboard with the following triggers: `account.invalid`, `account.stopped`, `job.successful`, `job.failed`
