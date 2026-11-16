//! Thin `wasm-bindgen` layer around `routing`, loaded by the PWA in a Web Worker.

use wasm_bindgen::prelude::*;

/// Version of the routing code, so the PWA can check which build it loaded.
#[wasm_bindgen]
pub fn version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}
