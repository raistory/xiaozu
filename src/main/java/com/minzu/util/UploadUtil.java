package com.minzu.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;
import java.util.UUID;

public class UploadUtil {

    private UploadUtil() {}

    public static String getUploadDir() {
        String dir = System.getProperty("upload.dir");
        if (dir != null && !dir.trim().isEmpty()) {
            return dir.trim();
        }
        return System.getProperty("user.home") + File.separator + "minzu-secondhand-uploads";
    }

    public static String saveFile(Part part, String uploadPath, HttpServletRequest request) throws Exception {
        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) return null;
        String ext = "";
        int dot = submittedFileName.lastIndexOf(".");
        if (dot != -1) ext = submittedFileName.substring(dot);
        String newFileName = UUID.randomUUID().toString().replace("-", "") + ext;
        part.write(uploadPath + File.separator + newFileName);
        return request.getContextPath() + "/uploads/" + newFileName;
    }
}
