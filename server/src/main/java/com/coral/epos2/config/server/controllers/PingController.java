package com.coral.epos2.config.server.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PingController {

    @RequestMapping(value = "/ping", method = RequestMethod.GET)
    public void respondToPing() {

        return;
    }

}
