package com.pahana_edu.mypro.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.UUID;

public class FileUploadUtil {
    public static String uploadFile(Part part, String uploadDirectory, HttpServletRequest request) throws IOException {
        // Get the application's real path
        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + uploadDirectory;

        // Create the upload directory if it doesn't exist
        Files.createDirectories(Paths.get(uploadPath));

        // Generate a unique filename
        String fileName = part.getSubmittedFileName();
        String fileExtension = fileName.substring(fileName.lastIndexOf("."));
        String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

        // Save the file
        part.write(uploadPath + File.separator + uniqueFileName);

        // Return the relative path to store in database
        return uploadDirectory + "/" + uniqueFileName;
    }
}