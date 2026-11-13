# Intégration de l'espace administrateur E-TECH

Une branche `feature/admin-dashboard` contient une première base de l'espace privé à l'adresse `/admin/`.

## Important : l'espace n'est pas encore activé
GitHub Pages ne fournit pas de base de données. Il faut créer un projet Supabase et appliquer les étapes ci-dessous avant d'utiliser le tableau de bord.

## Configuration Supabase
1. Créez un projet sur https://supabase.com/.
2. Dans SQL Editor, exécutez tout le contenu de `supabase/schema.sql`.
3. Dans Authentication > Users, créez votre utilisateur administrateur avec un email et un mot de passe fort.
4. Dans SQL Editor, exécutez cette requête en remplaçant l'adresse :
   ```sql
   insert into public.admin_users(user_id,email)
   select id,email from auth.users where email='VOTRE_EMAIL_ADMIN';
   ```
5. Copiez `supabase-config.example.js` vers `supabase-config.js`, puis renseignez l'URL du projet et la clé anon/publishable dans Project Settings > API.
6. Ne publiez jamais la clé `service_role`. La clé anon/publishable est prévue pour le navigateur ; les politiques RLS limitent l'accès aux données.
7. Activez GitHub Pages sur la branche après revue/merge.

## Ce que contient cette première étape
- Connexion admin par Supabase Auth et liste blanche `admin_users`.
- Vues commandes, clients/historique, produits, abonnements et statistiques.
- Modification des statuts de commande et de paiement.
- Ajout et activation/masquage des produits.
- Suivi des dates d'expiration des abonnements.
- Schéma SQL avec RLS : les visiteurs peuvent créer une commande, mais ne peuvent pas lire les commandes, clients ni abonnements.

## À finaliser avant mise en production
- Créer `supabase-config.js` (il ne doit pas être commité dans un dépôt public ; ajoutez-le à `.gitignore`).
- Relier le formulaire de commande de `index.html` aux tables `customers` et `orders` : cette branche ne migre pas encore les commandes du stockage local.
- Faire un test de bout en bout avec une commande fictive et vérifier les règles RLS.
- Si vous collectez des preuves de paiement, les stocker dans un bucket privé Supabase Storage avec des politiques dédiées. Ne stockez pas seulement le nom du fichier.
- Vérifier les obligations légales, la protection des données et les droits de distribution des services vendus.

Les commandes déjà présentes dans le `localStorage` des clients ne sont pas transférées automatiquement : elles restent sur leurs appareils.
