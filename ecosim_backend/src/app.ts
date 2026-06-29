import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { register, login } from './controllers/authController';
import { createOrUpdateVillage, getActiveVillage } from './controllers/villageController';
import { createAssessment, getLatestAssessment } from './controllers/assessmentController';
import { createScenario, getScenarios, runScenarioAnalysis, runScenarioBlueprint } from './controllers/scenarioController';
import { authMiddleware } from './middlewares/authMiddleware';

import path from 'path';
import fs from 'fs';

const nodeEnv = process.env.NODE_ENV || 'development';
const envPath = path.resolve(process.cwd(), `.env.${nodeEnv}`);
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
} else {
  dotenv.config();
}

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());

app.use(express.json());

app.post('/api/auth/register', register);
app.post('/api/auth/login', login);

app.post('/api/villages', authMiddleware as any, createOrUpdateVillage as any);
app.get('/api/villages/active', authMiddleware as any, getActiveVillage as any);

app.post('/api/assessments', authMiddleware as any, createAssessment as any);
app.get('/api/assessments/latest', authMiddleware as any, getLatestAssessment as any);

app.post('/api/scenarios', authMiddleware as any, createScenario as any);
app.get('/api/scenarios', authMiddleware as any, getScenarios as any);
app.post('/api/scenarios/:id/analyst', authMiddleware as any, runScenarioAnalysis as any);
app.post('/api/scenarios/:id/blueprint', authMiddleware as any, runScenarioBlueprint as any);

app.get('/', (req, res) => {
  res.status(200).send('EcoSim Desa Backend API is running perfectly!');
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date() });
});

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({
    error: 'Terjadi kesalahan internal pada server.',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

if (process.env.NODE_ENV !== 'production') {
  app.listen(port, () => {
    console.log(`Server EcoSim Desa Backend berjalan di port ${port}`);
  });
}

export default app;
