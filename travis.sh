set -e
set -x

if [ "$MEQP_CHECK" = "true" ];
then
    mkdir -p lib/Mollie/Composer lib/Mollie/GuzzleHttp lib/Mollie lib/Mollie/Psr

    mv vendor/composer/ca-bundle lib/Mollie/Composer/CaBundle
    mv vendor/guzzlehttp/guzzle lib/Mollie/GuzzleHttp/Guzzle
    mv vendor/guzzlehttp/promises lib/Mollie/GuzzleHttp/Promises
    mv vendor/guzzlehttp/psr7 lib/Mollie/GuzzleHttp/Psr7
    mv vendor/mollie/mollie-api-php lib/Mollie/Mollie
    mv vendor/psr/http-message lib/Mollie/Psr/HttpMessage
    rm -rf lib/Mollie/Mollie/examples

    git apply guzzle-coding-standards-fix.patch

    composer global config http-basic.repo.magento.com $MAGENTO_USERNAME $MAGENTO_PASSWORD
    composer config repositories.repo-magento-com composer https://repo.magento.com
    composer require --no-interaction magento/marketplace-eqp

    vendor/bin/phpcs --config-set installed_paths vendor/magento/marketplace-eqp
    vendor/bin/phpcs -p --ignore=*/vendor/*,*/Tests/* -n --severity=9 --standard="MEQP1" --severity=10 *
fi

if [ "$CREATE_RELEASE" = "true" ];
then
    git archive --format=zip --output=Mollie_Payment.zip $TRAVIS_COMMIT
    zip -ur Mollie_Payment.zip lib
fi