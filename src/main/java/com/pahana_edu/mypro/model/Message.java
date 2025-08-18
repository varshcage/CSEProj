package com.pahana_edu.mypro.model;

public class Message {
    private String text;
    private String type; // "success", "error", "info"

    public Message(String text, String type) {
        this.text = text;
        this.type = type;
    }

    public String getText() {
        return text;
    }

    public String getType() {
        return type;
    }
}