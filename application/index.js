'use strict';

const express = require('express');

const {
    HOST,
    HOSTNAME,
    PORT,
    VERSION,
} = process.env;

const main = () => {

    const app = express();

    app.get(
        '/',
        (request, response) => {
            response.send(
                `${VERSION} (${HOSTNAME})\n`
            );
        }
    );

    app.listen(PORT, HOST);

    console.log(`Application ${VERSION} (${HOSTNAME}) is running on http://${HOST}:${PORT}`);
}

// We are simulating a warm-up delay of the service.
setTimeout(main, 5000);
