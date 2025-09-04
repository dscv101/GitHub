use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Cli {
    /// Your name
    #[arg(short, long, default_value = "world")]
    name: String,
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    println!("Hello, {}!", cli.name);
    Ok(())
}
