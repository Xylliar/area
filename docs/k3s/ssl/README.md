# Simple Guide: Set Up SSL with Let’s Encrypt on k3s

This guide will walk you through setting up SSL for your k3s cluster using Let's Encrypt and cert-manager. You’ll be able to secure your services using HTTPS for your domain. In this example, we use `area.skead.fr`, but you can replace it with your own domain.

## Prerequisites

Before you start:
- You should have **k3s** running.
- A **domain** name (like `area.skead.fr`) that points to your server’s IP address.
- **Traefik** Ingress controller, which is included by default with k3s.

---

## Step 1: Install cert-manager

cert-manager is a tool that automatically gets and renews SSL certificates.

### Install with kubectl (recommended)

If you don't have Helm, use this command:

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.16.1/cert-manager.yaml
```

---

### Install with Helm

1. **Add cert-manager repository**:

   ```bash
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   ```

2. **Install cert-manager in the cert-manager namespace**:

   ```bash
   kubectl create namespace cert-manager

   helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --version v1.11.0 \
     --set installCRDs=true
   ```


## Step 2: Create Let’s Encrypt Certificate Issuer

This tells cert-manager to use Let’s Encrypt to request and renew certificates for your domain.

1. **Create a file** called `cluster-issuer.yaml`:

   ```bash
   nano cluster-issuer.yaml
   ```

2. **Add this content**:

   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-production
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email: your-email@example.com  # Replace with your email /!\
       privateKeySecretRef:
         name: letsencrypt-production
       solvers:
       - http01:
           ingress:
             class: traefik
   ```

3. **Apply the file**:

   ```bash
   kubectl apply -f cluster-issuer.yaml
   ```

---

## Step 3: Create an Ingress to Handle SSL

1. **Create another file** called `ingress.yaml`:

   ```bash
   nano ingress.yaml
   ```

2. **Add this content** to configure how traffic will reach your services and set up SSL:

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: api-ingress
     annotations:
       cert-manager.io/cluster-issuer: letsencrypt-production
   spec:
     ingressClassName: traefik
     tls:
     - hosts:
       - area.skead.fr  # Replace with your domain /!\
       secretName: area-skead-fr-tls
     rules:
     - host: area.skead.fr  # Replace with your domain /!\
       http:
         paths:
         - path: /discord
           pathType: Prefix
           backend:
             service:
               name: discord-service
               port:
                 number: 80
         - path: /google
           pathType: Prefix
           backend:
             service:
               name: drive-service
               port:
                 number: 80
         - path: /time
           pathType: Prefix
           backend:
             service:
               name: time-service
               port:
                 number: 80
   ```

3. **Apply the file**:

   ```bash
   kubectl apply -f ingress.yaml
   ```

---

## Step 4: Check SSL Certificate Status

Now cert-manager will automatically request a certificate from Let’s Encrypt. Here’s how to check its status:

1. **Check the certificate**:

   ```bash
   kubectl describe certificate area-skead-fr-tls
   ```

   Look for a message that says "Certificate issued successfully."

2. **Check cert-manager logs for more details**:

   ```bash
   kubectl logs -n cert-manager deploy/cert-manager
   ```

---

## Step 5: Test Your HTTPS Setup

Once the certificate is issued, go to your domain in the browser:

- Visit: `https://area.skead.fr` (or replace with your own domain).

If everything worked, you should see the website secured with HTTPS.

---

## Debugging Issues

If the certificate isn’t being issued, here are simple checks to troubleshoot:

1. **Check DNS**: Ensure your domain points to the right IP address.

   Run this command to verify:

   ```bash
   nslookup area.skead.fr  # Replace with your domain
   ```

2. **Inspect ACME Challenge**: cert-manager uses the HTTP-01 challenge to verify your domain ownership.

   Run this to see details:

   ```bash
   kubectl describe challenge -n default -l acme.cert-manager.io/domain=area.skead.fr
   ```

3. **Look at Ingress**: Ensure the ingress is properly configured to handle traffic.

   ```bash
   kubectl describe ingress api-ingress
   ```

4. **Check cert-manager logs**:

   ```bash
   kubectl logs -n cert-manager deploy/cert-manager
   ```

If you see any errors, fix them based on the feedback from these checks.

---

## Conclusion

You’ve successfully set up SSL for your k3s cluster using Let’s Encrypt! Your services are now accessible via HTTPS.