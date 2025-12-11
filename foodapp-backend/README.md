# Foodago Backend (Node.js + Express + MongoDB Atlas)

## Quick setup

1. Clone/copy this folder.
2. `cd foodapp-backend`
3. `npm install`
4. Create `.env` (see `.env.example`) and set:
   - `MONGODB_URI` (your Atlas connection string)
   - `JWT_SECRET` (long random string)
5. Seed example products:
   - `npm run seed`
6. Start server:
   - `npm run dev` (nodemon, recommended) or `npm start`
7. API root: `http://localhost:4000/`

## API Endpoints

- `POST /api/auth/register` — { name, email, password, phone } => `{ token, user }`
- `POST /api/auth/login` — { email, password } => `{ token, user }`
- `GET /api/auth/me` — (protected via `Authorization: Bearer <token>`) => user data
- `GET /api/products` — optional query `?q=search&category=Combos`
- `GET /api/products/:id`

## Notes

- This is a starter backend. For production:
  - Use HTTPS
  - Use stronger JWT rotation / refresh tokens
  - Add rate-limiting, logging, and input sanitization
  - Add email verification and password reset flows
