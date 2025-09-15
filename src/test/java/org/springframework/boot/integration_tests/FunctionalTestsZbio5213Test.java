
    package org.springframework.boot.integration_tests;
  
    import com.intuit.karate.Results;
    import com.intuit.karate.Runner;
    // import com.intuit.karate.http.HttpServer;
    // import com.intuit.karate.http.ServerConfig;
    import org.junit.jupiter.api.Test;
  
    import static org.junit.jupiter.api.Assertions.assertEquals;
  
    class FunctionalTestsZbio5213Test {
  
        @Test
        void testAll() {
            String zbio_5213_026a11b060_url = System.getenv().getOrDefault("ZBIO_5213_026A11B060_URL", "https://127.0.0.1:4010");
String zbio_5213_026a11b060_auth_token = System.getenv().getOrDefault("ZBIO_5213_026A11B060_AUTH_TOKEN", "dummy_ZBIO_5213_026A11B060_AUTH_TOKEN");
String auth_token = System.getenv().getOrDefault("AUTH_TOKEN", "dummy_AUTH_TOKEN");
            Results results = Runner.path("src/test/java/org/springframework/boot/integration_tests/FunctionalTestsZbio5213")
                    .systemProperty("ZBIO_5213_026A11B060_URL",zbio_5213_026a11b060_url)
.systemProperty("ZBIO_5213_026A11B060_AUTH_TOKEN", zbio_5213_026a11b060_auth_token)
.systemProperty("AUTH_TOKEN", auth_token)
                    .reportDir("testReport").parallel(1);
            assertEquals(0, results.getFailCount(), results.getErrorMessages());
        }
  
    }
