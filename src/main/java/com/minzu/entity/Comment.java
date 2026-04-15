package com.minzu.entity;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Comment {
    private int commentId;
    private int productId;
    private int userId;
    private String content;
    private Integer parentId;
    private Timestamp createdAt;

    private String userNickname;
    private String userRealName;
    private List<Comment> replies = new ArrayList<>();

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserNickname() { return userNickname; }
    public void setUserNickname(String userNickname) { this.userNickname = userNickname; }

    public String getUserRealName() { return userRealName; }
    public void setUserRealName(String userRealName) { this.userRealName = userRealName; }

    public List<Comment> getReplies() { return replies; }
    public void setReplies(List<Comment> replies) { this.replies = replies; }

    public String getDisplayName() {
        if (userNickname != null && !userNickname.isEmpty()) return userNickname;
        if (userRealName != null && !userRealName.isEmpty()) return userRealName;
        return "匿名用户";
    }
}
