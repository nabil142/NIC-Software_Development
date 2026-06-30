import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma';

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkeyfordevelopmentonly';

export async function register(req: Request, res: Response) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email dan password wajib diisi.' });
  }

  try {

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(409).json({ error: 'Email sudah terdaftar.' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
      },
    });

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(201).json({
      message: 'Registrasi berhasil.',
      token,
      user: { id: user.id, email: user.email },
    });
  } catch (err: any) {
    console.error('Error saat registrasi:', err);
    return res.status(500).json({ error: err.message || 'Gagal mendaftarkan pengguna.' });
  }
}

export async function login(req: Request, res: Response) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email dan password wajib diisi.' });
  }

  try {

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(401).json({ error: 'Email atau password salah.' });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Email atau password salah.' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(200).json({
      message: 'Login berhasil.',
      token,
      user: { id: user.id, email: user.email },
    });
  } catch (err: any) {
    console.error('Error saat login:', err);
    return res.status(500).json({ error: err.message || 'Gagal masuk sistem.' });
  }
}

export async function deleteAccount(req: Request, res: Response) {
  // @ts-ignore - req.user is populated by authMiddleware
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ error: 'Tidak ada akses untuk menghapus akun.' });
  }

  try {
    // Karena onDelete: Cascade, menghapus User akan menghapus Village, Assessment, dll
    await prisma.user.delete({
      where: { id: userId },
    });

    return res.status(200).json({ message: 'Akun berhasil dihapus permanen.' });
  } catch (err: any) {
    console.error('Error saat menghapus akun:', err);
    return res.status(500).json({ error: err.message || 'Gagal menghapus akun.' });
  }
}
