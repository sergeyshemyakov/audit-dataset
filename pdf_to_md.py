import os
import glob
import pymupdf4llm

# PyMuPDF4LLM's layout converter currently detects link annotations but does
# not emit them. Its legacy converter resolves annotations to Markdown links.
pymupdf4llm.use_layout(False)

def batch_convert_pdfs():
    # Find PDFs in the current directory and all non-hidden subdirectories.
    pdf_files = sorted(
        path
        for path in glob.glob("**/*.[pP][dD][fF]", recursive=True)
        if os.path.isfile(path)
    )
    
    if not pdf_files:
        print("No PDF files found in the current directory or its subdirectories.")
        return

    print(f"Found {len(pdf_files)} PDF(s). Starting conversion...\n")

    for pdf in pdf_files:
        print(f"Processing: {pdf}")

        # Skip PDFs that already have a Markdown file next to them.
        base_name = os.path.splitext(pdf)[0]
        output_file = f"{base_name}.md"
        if os.path.isfile(output_file):
            print(f"  -> Skipped; {output_file} already exists")
            continue

        try:
            # Convert PDF to Markdown. 
            # write_images=False skips images, keeping the text clean for AI.
            md_text = pymupdf4llm.to_markdown(
                pdf,
                write_images=False,
                ignore_graphics=True,
                ignore_images=True,
            )

            # Save to Markdown
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(md_text)
                
            print(f"  -> Saved to {output_file}")
            
        except Exception as e:
            print(f"  -> Error processing {pdf}: {e}")

if __name__ == "__main__":
    batch_convert_pdfs()
    print("\nBatch conversion completed!")
