const lwcConfig = require('@salesforce/eslint-config-lwc');
const lockerConfig = require('@locker/eslint-config-locker/recommended');

module.exports = [
    {
        ignores: [
            '**/lwc/**/*.css',
            '**/lwc/**/*.html',
            '**/lwc/**/*.json',
            '**/lwc/**/*.svg',
            '**/lwc/**/*.xml',
            '**/aura/**/*.auradoc',
            '**/aura/**/*.cmp',
            '**/aura/**/*.css',
            '**/aura/**/*.design',
            '**/aura/**/*.evt',
            '**/aura/**/*.json',
            '**/aura/**/*.svg',
            '**/aura/**/*.xml',
            '**/aura/**/*.tokens',
            '.sfdx',
            '**/lwc/pubsub/README.md'
        ]
    },
    ...lwcConfig.configs.recommended,
    ...lockerConfig,
    {
        languageOptions: {
            ecmaVersion: 12,
            sourceType: 'module'
        }
    }
];
