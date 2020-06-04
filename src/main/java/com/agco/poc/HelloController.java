package com.agco.poc;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.CrossOrigin;

@CrossOrigin
@RestController
@RequestMapping("/api")
public class HelloController {

    @RequestMapping("/")
    public String index() {
        return "Hello from AGCO example backend!";
    }

    @RequestMapping("/json")
    public String jsonResponse() {
        return "{\"everythingWorks\": true}";
    }
}