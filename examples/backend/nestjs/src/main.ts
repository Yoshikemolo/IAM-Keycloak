/**
 * @file NestJS application bootstrap.
 *
 * Configures Handlebars as the view engine, serves static assets from
 * the `public/` directory, and sets up Express sessions for Passport
 * OIDC authentication.
 */

import 'reflect-metadata';
import { config } from 'dotenv';
config();

import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import hbs from 'hbs';
import session from 'express-session';
import passport from 'passport';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // ----- View engine (Handlebars) -----
  const viewsDir = join(__dirname, '..', 'views');
  app.setBaseViewsDir(viewsDir);
  app.setViewEngine('hbs');
  hbs.registerPartials(join(viewsDir, 'partials'));

  // Register Handlebars helpers
  hbs.registerHelper('eq', (a: unknown, b: unknown) => a === b);
  hbs.registerHelper('json', (context: unknown) => JSON.stringify(context, null, 2));
  hbs.registerHelper('year', () => new Date().getFullYear());
  hbs.registerHelper('includes', (arr: unknown[], value: unknown) => {
    if (Array.isArray(arr)) {
      return arr.includes(value);
    }
    return false;
  });

  // ----- Static assets -----
  app.useStaticAssets(join(__dirname, '..', 'public'));

  // ----- Sessions -----
  app.use(
    session({
      secret: process.env.SESSION_SECRET || 'nestjs-iam-secret',
      resave: false,
      saveUninitialized: false,
      cookie: {
        maxAge: 3600000, // 1 hour
        secure: false,
      },
    }),
  );

  // ----- Passport -----
  app.use(passport.initialize());
  app.use(passport.session());

  const port = parseInt(process.env.PORT || '3001', 10);
  await app.listen(port);
  console.log(`NestJS IAM example running on http://localhost:${port}`);
}

bootstrap();
