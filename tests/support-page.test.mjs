import test from 'node:test';import assert from 'node:assert/strict';
import {renderSupportPage} from '../commerce/support-page.mjs';
test('static support page explicitly states unverified, no checkout or downloads',()=>{const x=renderSupportPage();assert.match(x,/미검증/);assert.match(x,/다운로드 및 문의 접수 서비스를 제공하지 않습니다/);assert.match(x,/script-src 'none'/);assert.match(x,/form-action 'none'/);assert.doesNotMatch(x,/<script\b|<form\b|https?:\/\//i)});
test('FAQ retains Korean branding and source catalog route',()=>{const x=renderSupportPage();assert.match(x,/AXMART³/);assert.match(x,/href="\/products\/"/)});
