use clap::Parser;
use std::fs;
use std::io::{self, Write};
use std::path::PathBuf;
use walkdir::WalkDir;

/// Recursively find and delete directories by name under the current directory.
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Opt {
    /// Folder name to delete. Can be used multiple times.
    #[arg(short = 'f', long = "folder")]
    folder: Vec<String>,

    /// Do not prompt for confirmation
    #[arg(short = 'y', long = "yes")]
    yes: bool,

    /// Show what would be deleted without actually deleting
    #[arg(long = "dry-run")]
    dry_run: bool,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opt = Opt::parse();

    if opt.folder.is_empty() {
        eprintln!("请至少通过 --folder/-f 提供一个要删除的文件夹名称。");
        std::process::exit(2);
    }

    // Collect matching directories
    let mut matches: Vec<PathBuf> = Vec::new();
    for entry in WalkDir::new(".").into_iter().filter_map(|e| e.ok()) {
        if entry.file_type().is_dir() {
            let name = entry.file_name().to_string_lossy().to_string();
            if opt.folder.iter().any(|f| f == &name) {
                // skip the current directory itself (i.e., '.'), and ensure not trying to remove root
                let path = entry
                    .path()
                    .canonicalize()
                    .unwrap_or_else(|_| entry.path().to_path_buf());
                matches.push(path);
            }
        }
    }

    if matches.is_empty() {
        println!("没有找到匹配的文件夹要删除。给定的名称: {:?}", opt.folder);
        return Ok(());
    }

    // Remove duplicates and sort for deterministic order
    matches.sort();
    matches.dedup();

    println!("找到 {} 个匹配的目录:", matches.len());
    for p in &matches {
        println!("  {}", p.display());
    }

    if opt.dry_run {
        println!("--dry-run: 不会进行实际删除。");
        return Ok(());
    }

    if !opt.yes {
        print!("确认删除以上所有目录？输入 y 确认: ");
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        let input = input.trim().to_lowercase();
        if input != "y" && input != "yes" {
            println!("已取消。");
            return Ok(());
        }
    }

    // Perform deletions
    let mut failed = 0usize;
    for p in &matches {
        // Safety: ensure path is inside current working directory
        let cwd = std::env::current_dir()?.canonicalize()?;
        let pcanon = p.canonicalize().unwrap_or_else(|_| p.clone());
        if !pcanon.starts_with(&cwd) {
            eprintln!("跳过不在当前目录下的路径: {}", p.display());
            failed += 1;
            continue;
        }

        match fs::remove_dir_all(&p) {
            Ok(_) => println!("已删除: {}", p.display()),
            Err(e) => {
                eprintln!("删除失败 {}: {}", p.display(), e);
                failed += 1;
            }
        }
    }

    if failed > 0 {
        eprintln!("完成，但有 {} 个删除失败。", failed);
        std::process::exit(1);
    }

    println!("执行完毕");
    Ok(())
}
