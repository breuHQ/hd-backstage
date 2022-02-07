// import { TraceExporter as Exporter } from '@google-cloud/opentelemetry-cloud-trace-exporter';
// import opentelemetry from '@opentelemetry/api';
// import { AlwaysOnSampler } from '@opentelemetry/core';
// import { registerInstrumentations } from '@opentelemetry/instrumentation';
// import { ExpressInstrumentation } from '@opentelemetry/instrumentation-express';
// import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
// import { Resource } from '@opentelemetry/resources';
// import {
//   SimpleSpanProcessor,
//   ConsoleSpanExporter,
// } from '@opentelemetry/sdk-trace-base';
// import { NodeTracerProvider } from '@opentelemetry/sdk-trace-node';
// import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

// export const tracer = (serviceName: string) => {
//   const provider = new NodeTracerProvider({
//     resource: new Resource({
//       [SemanticResourceAttributes.SERVICE_NAME]: serviceName,
//     }),
//     sampler: new AlwaysOnSampler(),
//   });

//   registerInstrumentations({
//     tracerProvider: provider,
//     instrumentations: [
//       // Express instrumentation expects HTTP layer to be instrumented
//       new HttpInstrumentation(),
//       new ExpressInstrumentation(),
//     ],
//   });

//   //   const exporter = new Exporter();
//   const exporter = new ConsoleSpanExporter();

//   provider.addSpanProcessor(new SimpleSpanProcessor(exporter));

//   // Initialize the OpenTelemetry APIs to use the NodeTracerProvider bindings
//   provider.register();

//   return opentelemetry.trace.getTracer('express-example');
// };

import process from 'process';
import * as opentelemetry from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { ConsoleSpanExporter } from '@opentelemetry/sdk-trace-base';
import { TraceExporter } from '@google-cloud/opentelemetry-cloud-trace-exporter';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

// configure the SDK to export telemetry data to the console
// enable all auto-instrumentations from the meta package
export const tracer = (serviceName: string) => {
  //   const traceExporter = new ConsoleSpanExporter();
  const traceExporter = new TraceExporter();
  const sdk = new opentelemetry.NodeSDK({
    resource: new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: serviceName,
    }),
    traceExporter,
    instrumentations: [getNodeAutoInstrumentations()],
  });

  // initialize the SDK and register with the OpenTelemetry API
  // this enables the API to record telemetry
  sdk
    .start()
    .then(() => console.log('Tracing initialized'))
    .catch((error: any) => console.log('Error initializing tracing', error));

  // gracefully shut down the SDK on process exit
  process.on('SIGTERM', () => {
    sdk
      .shutdown()
      .then(() => console.log('Tracing terminated'))
      .catch((error: any) => console.log('Error terminating tracing', error))
      .finally(() => process.exit(0));
  });
};
