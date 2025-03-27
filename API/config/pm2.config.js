module.exports = {
    apps: [
        {
            name: 'api-comentarios',
            script: 'server.js',
            instances: 2,
            exec_mode: 'cluster',
            watch: true,
            autorestart: true,
            max_memory_restart: '200M'
        }
    ]
};
