package com.aialpha.sentiment.metrics;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.DistributionSummary;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class SentimentMetrics {

    private final MeterRegistry meterRegistry;

    private final AtomicInteger lastCompaniesDetected;

    public SentimentMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        this.lastCompaniesDetected = meterRegistry.gauge(
                "sentiment.companies.detected.last",
                new AtomicInteger(0)
        );
        }


    public void recordAnalysis(String sentiment, String company) {
        Counter.builder("sentiment.analysis.total")
                .tag("sentiment", sentiment)
                .tag("company", company)
                .description("Total number of sentiment analysis requests")
                .register(meterRegistry)
                .increment();
    }


    public void recordDuration(long milliseconds, String company, String model) {
        Timer.builder("sentiment.analysis.duration")
                .tag("company", company)
                .tag("model", model)
                .description("Duration of sentiment analysis / Bedrock API call in milliseconds")
                .register(meterRegistry)
                .record(milliseconds, TimeUnit.MILLISECONDS);
    }

    public void recordCompaniesDetected(int count) {
        if (lastCompaniesDetected != null) {
            lastCompaniesDetected.set(count);
        }
    }


    public void recordConfidence(double confidence, String sentiment, String company) {
        DistributionSummary.builder("sentiment.confidence.distribution")
                .tag("sentiment", sentiment)
                .tag("company", company)
                .description("Distribution of sentiment confidence scores (0.0 - 1.0)")
                .register(meterRegistry)
                .record(confidence);
    }
}
