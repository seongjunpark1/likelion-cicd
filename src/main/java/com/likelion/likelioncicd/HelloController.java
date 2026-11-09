package com.likelion.likelioncicd;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @Value("${APP_COLOR:local}")
    private String color;

    @GetMapping("/")
    public String hello() {
        return "Hi, 아기사자! v1 (" + color + ")";
    }
}