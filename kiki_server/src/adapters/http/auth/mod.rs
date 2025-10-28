pub mod controller;
pub mod routes;

pub use controller::AuthController;
pub use routes::{login, register, AuthControllerProvider};
