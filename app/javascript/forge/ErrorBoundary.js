import React from 'react';
import { Notifier } from '@airbrake/browser';

class ErrorBoundary extends React.PureComponent {
    constructor(props) {
        super(props);
        this.state = { hasError: false };
        if (window.airbrakeCreds) {
            this.airbrake = new Notifier({
                projectId: window.airbrakeCreds.app_id,
                projectKey: window.airbrakeCreds.api_key,
                host: window.airbrakeCreds.host
            });
        }
    }

    componentDidCatch(error, info) {
        // Display fallback UI
        this.setState({ hasError: true });
        // Send error to Airbrake
        if (window.env === 'production' && this.airbrake) {
            this.airbrake.notify({
                error: error,
                params: {info: info}
            });
        }
    }

    render() {
        if (this.state.hasError) {
            // You can render any custom fallback UI
            // if (window.env === 'production')
                // .then(() => document.location.reload())
            return <h1>Something went wrong.</h1>;
        }
        return this.props.children;
    }
}

export default ErrorBoundary;
