/**
 * @file Application route definitions.
 *
 * Defines all client-side routes for the Angular IAM example,
 * matching the route structure of the React example:
 * - `/`            - Public home page
 * - `/dashboard`   - Protected (requires authentication)
 * - `/admin`       - Protected (requires authentication + admin role)
 * - `/profile`     - Protected (requires authentication)
 * - `/unauthorized`- Public error page for insufficient permissions
 * - `/callback`    - OIDC redirect handler
 * - `**`           - Not Found (404) page
 */

import { Routes } from '@angular/router';
import { authGuard } from '@app/auth/auth.guard';
import { roleGuard } from '@app/auth/role.guard';

import { HomeComponent } from '@app/pages/home/home.component';
import { DashboardComponent } from '@app/pages/dashboard/dashboard.component';
import { AdminComponent } from '@app/pages/admin/admin.component';
import { ProfileComponent } from '@app/pages/profile/profile.component';
import { UnauthorizedComponent } from '@app/pages/unauthorized/unauthorized.component';
import { CallbackComponent } from '@app/pages/callback/callback.component';
import { NotFoundComponent } from '@app/pages/not-found/not-found.component';

/**
 * Application route table.
 *
 * Protected routes use the {@link authGuard} to enforce login.
 * The admin route additionally uses the {@link roleGuard} factory
 * to require the `admin` realm role.
 */
export const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [authGuard],
  },
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [authGuard, roleGuard('admin')],
  },
  {
    path: 'profile',
    component: ProfileComponent,
    canActivate: [authGuard],
  },
  {
    path: 'unauthorized',
    component: UnauthorizedComponent,
  },
  {
    path: 'callback',
    component: CallbackComponent,
  },
  {
    path: '**',
    component: NotFoundComponent,
  },
];
