-- Enable pg_trgm extension for trigram similarity
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE TABLE IF NOT EXISTS achievement (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
-- Create trigram index for similarity searches
CREATE INDEX IF NOT EXISTS achievement_name_trgm_idx ON achievement USING GIN (name gin_trgm_ops);
INSERT INTO achievement (name)
VALUES -- Sales & Performance Achievements
    ('Top Seller 2024'),
    ('Top Seller 2023'),
    ('Best Sales Performance Q4 2024'),
    ('Sales Excellence Award'),
    ('Million Dollar Club Member'),
    -- Cloud & Technology Certifications
    ('AWS Solutions Architect Associate'),
    ('AWS Solutions Architect Professional'),
    ('AWS Developer Associate'),
    ('AWS SysOps Administrator Associate'),
    ('Azure Administrator Associate'),
    ('Azure Solutions Architect Expert'),
    ('Google Cloud Professional Architect'),
    ('Kubernetes Administrator Certified'),
    -- Programming & Development
    ('Full Stack Developer Expert'),
    ('Frontend Master'),
    ('Backend Specialist'),
    ('React Ninja'),
    ('Vue.js Expert'),
    ('Node.js Professional'),
    ('Python Developer'),
    ('Go Programming Master'),
    ('Java Enterprise Architect'),
    -- Project & Team Achievements
    ('Agile Scrum Master Certified'),
    ('Product Owner Professional'),
    ('Team Leadership Excellence'),
    ('Project Delivery Champion'),
    ('Cross-Functional Collaboration Award'),
    -- Learning & Innovation
    ('Continuous Learning Champion'),
    ('Innovation Award 2024'),
    ('Best Practice Implementer'),
    ('Knowledge Sharing Star'),
    ('Mentorship Excellence'),
    -- Security & Quality
    ('Security Best Practices Certified'),
    ('Code Quality Guardian'),
    ('DevSecOps Professional'),
    ('Penetration Testing Expert'),
    -- Thai Language Achievements (for mixed language testing)
    ('ผู้ขายยอดเยี่ยม 2024'),
    ('นักพัฒนาซอฟต์แวร์มืออาชีพ'),
    ('รางวัลนวัตกรรมดีเด่น'),
    -- Common variations and edge cases
    ('Top Performer'),
    ('Best Performer'),
    ('AWS Cert'),
    ('Cloud Architect'),
    ('Database Administrator'),
    ('DB Admin Expert'),
    ('Senior Developer'),
    ('Lead Engineer');