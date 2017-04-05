# Rust

![Rust Logo](rust-logo.svg)

---

# `about:emilio`

---

# Instalación

## Linux / OSX

```
$ curl https://sh.rustup.rs -sSf | sh
```

## Windows

https://win.rustup.rs

## Playground

https://play.rust-lang.org

---

```
$ cargo new --bin hello-world
Created binary (application) `hello-rust` project
```

```
$ cd hello-rust
```

```
$ cargo run
   Compiling hello-rust v0.1.0 (file:///home/emilio/projects/rust-talk/hello-rust)
    Finished dev [unoptimized + debuginfo] target(s) in 0.56 secs
     Running `target/debug/hello-rust`
Hello, world!
```

---

## Cargo.toml

```
[package]
name = "hello-rust"
version = "0.1.0"
authors = ["Emilio Cobos Álvarez <emilio@crisal.io>"]

[dependencies]
```

## src/main.rs

```rust
fn main() {
    println!("Hello, world!");
}
```

---

# Características

 * *Memory safety* sin recolector de basura (ownership y borrowing).
 * Concurrencia sin *data races*.
 * ADT (*Algebraic Data Types*).
 * Closures.
 * Pattern matching.

---

## Ownership

Como `std::move` de C++, pero por defecto, y exclusivo.

```rust
fn print_vector(v: Vec<i32>) {
    for value in v {
        println!("{}", value);
    }
}

fn main() {
    let v = vec![0, 1, 2];
    print_vector(v); // Toma "posesión" del valor.
    // No podemos usar v aquí, ha sido movido.
}
```

---

# Borrowing

```rust
fn print_vector(v: &Vec<i32>) { // Nótese el &, recibe una referencia.
    for value in v {
        println!("{}", value);
    }
}

fn main() {
    let v = vec![0, 1, 2];
    print_vector(&v); // "Prestamos" el vector a la función
    println!("{}", v[0]); // Aquí nos lo ha "devuelto"
}
```

---

```rust
fn add_to_vector(v: &mut Vec<i32>, value: i32) { // Nótese el &mut, recibe una
                                                 // referencia mutable.
    v.push(value);
}

fn main() {
    let mut v = vec![0, 1, 2];
    print_vector(&mut v, 4); // "Prestamos" el vector a la función
    assert_eq!(v.len(), 4); // Ya es nuestro otra vez.
}
```

---

 * Podemos prestar un valor *inmutablemente* a tantos consumidores como
   queramos a la vez.
 * Pero *mutablemente* sólo a uno.
 * Esta "restricción" resulta clave para garantizar concurrencia segura y
   memory safety.

---

```rust
fn add_to_vector(v: &mut Vec<i32>, value: i32) {
    v.push(value);
}

fn main() {
    let mut vector = vec![1, 2, 3];
    for value in &vector { // Presta inmutablemente.
        add_to_vector(&mut vector, *value);
        // Trata de prestar mutablemente, error de compilación:
    }
}
```

```
error[E0502]: cannot borrow `vector` as mutable because it is also borrowed as immutable
  --> src/main.rs:8:28
   |
7  |     for value in &vector { // Presta inmutablemente.
   |                   ------ immutable borrow occurs here
8  |         add_to_vector(&mut vector, *value);
   |                            ^^^^^^ mutable borrow occurs here
9  |         // Trata de prestar mutablemente, error de compilación:
10 |     }
   |     - immutable borrow ends here
```

---

```rust
fn main() {
    let y: &i32;
    {
        let v = vec![0, 1, 2];
        y = &v[0];
    }
    println!("Y es: {:?}", y);
}
```

```
error: `v` does not live long enough
 --> src/main.rs:6:5
  |
5 |         y = &v[0];
  |              - borrow occurs here
6 |     }
  |     ^ `v` dropped here while still borrowed
7 |     println!("Y es: {:?}", y);
8 | }
  | - borrowed value needs to live until here
```

---

# ADT

```rust
enum JsonValue {
    Null,
    Bool(bool),
    Number(f64),
    Str(String),
    List(Vec<JsonValue>),
    Object(HashMap<String, JsonValue>),
}
```

---

# Pattern matching

```rust
fn print_value(v: &JsonValue) {
    match *v {
        JsonValue::Null => print!("null"),
        JsonValue::Bool(v) => print!("{}", v),
        JsonValue::Number(v) => print!("{}", v),
        JsonValue::Str(ref string) => print!("\"{}\"", string), // TODO: escape
        JsonValue::List(ref v) => {
            print!("[");
            let mut first = true;
            for value in v {
                if !first {
                    print!(", ");
                }
                first = false;
                print_value(value);
            }
            print!("]");
        }
        JsonValue::Object(ref map) => {
            print!("{{");
            let mut first = true;
            for (key, value) in map.iter() {
                if !first {
                    print!(", ");
                }
                first = false;
                print!("\"{}\": ", key);
                print_value(value);
            }
            print!("}}");
        }
    }
}
```

# Traits y generics

```rust
fn write_value<W>(v: &JsonValue, dest: &mut W) -> io::Result
    where W: io::Write,
{
    match *v {
        JsonValue::Null => dest.write_str("null"),
        JsonValue::Bool(v) => write!(dest, "{}", v),
        // ...
    }
}

fn print_to_stdout(v: &JsonValue) {
    write_value(v, &mut io::stdout()).unwrap();
}

fn json_to_string(v: &JsonValue) -> String {
    let mut ret = String::new();
    write_value(v, &mut ret).unwrap();
    ret
}
```

---

# Concurrencia sin data races

```rust
extern crate rayon;
fn quick_sort<T: PartialOrd + Send>(v: &mut [T]) {
    if v.len() > 1 {
        let mid = partition(v);
        let (low, high) = v.split_at_mut(mid);
            rayon::join(|| quick_sort(low),
                        || quick_sort(high));
    }
}
fn partition<T: PartialOrd + Send>(xs: &mut [T]) -> usize {
    // ...
}
```

---

# Ecosistema

## Cargo, el gestor de paquetes

 * https://crates.io

## Docs.rs, hosting gratuito para documentación

 * https://docs.rs

---

# Preguntas?

---

# Ejercicios?

Se me han ocurrido algunos ejercicios que podíamos hacer entre todos (en
grupos?) para hacernos al lenguaje.

 * "Cutre-curl" (algo que reciba una página web por CLI y la imprima a stdout)
 * Algún ejercicio del hashcode? 😈
 * Ideas de programas simples y no tan simples?
