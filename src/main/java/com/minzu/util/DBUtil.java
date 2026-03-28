package com.minzu.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String URL = "jdbc:mysql://localhost:3306/minzu_secondhand?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "13579gdp";

    @FunctionalInterface
    public interface ConnectionSupplier {
        Connection get() throws SQLException;
    }

    private static ConnectionSupplier connectionSupplier = null;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("加载MySQL驱动失败", e);
        }
    }

    public static void setConnectionSupplier(ConnectionSupplier supplier) {
        connectionSupplier = supplier;
    }

    public static ConnectionSupplier getConnectionSupplier() {
        return connectionSupplier;
    }

    public static Connection getConnection() throws SQLException {
        if (connectionSupplier != null) {
            return connectionSupplier.get();
        }
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}