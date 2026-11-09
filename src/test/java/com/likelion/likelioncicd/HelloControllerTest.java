package com.likelion.likelioncicd;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class HelloControllerTest {

    @Test
    void 인사말에_Hello가_들어있다() {
        HelloController controller = new HelloController();
        assertThat(controller.hello()).contains("Hello");
    }
}