function generate_and_install(font_name::String="옛한글")
    # ... (previous code remains the same)
    
    # Save raw font data
    output_dir = "output/yethangle"
    println("Saving font data to $output_dir")
    save_font(font, output_dir)
    
    # Convert to TTF
    ttf_file = "output/yethangle.ttf"
    println("Converting to TTF format...")
    success = convert_to_ttf(font, ttf_file)
    
    if success
        # Clean up .bin files
        println("Cleaning up temporary files...")
        for file in readdir(output_dir)
            if endswith(file, ".bin")
                rm(joinpath(output_dir, file))
            end
        end
        
        # Install font
        println("Installing font...")
        install_font(ttf_file)
        println("Yethangle font successfully generated and installed!")
    else
        println("TTF conversion failed. Temporary files kept for debugging.")
    end
end
